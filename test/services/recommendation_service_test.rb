require "test_helper"

class RecommendationServiceTest < ActiveSupport::TestCase
  setup do
    @zoe = users(:one)  # female, pref male
    @jack = users(:two) # male

    @zoe.update!(pref_gender: :male)
    @zoe.update!(birthdate: 25.years.ago)
    @jack.update!(birthdate: 25.years.ago, verification_level: :id_verified)
  end

  test "queue contains verified candidates with disclosed gender, excluding self" do
    queue = RecommendationService.new(@zoe).queue
    assert_includes queue, @jack.id
    assert_not_includes queue, @zoe.id
  end

  test "queue excludes users with undisclosed gender" do
    @jack.update!(gender: :undisclosed)

    assert_not_includes RecommendationService.new(@zoe).queue, @jack.id
  end

  test "queue respects preferred gender" do
    @zoe.update!(pref_gender: :female)

    assert_not_includes RecommendationService.new(@zoe).queue, @jack.id
  end

  test "queue respects age range" do
    @jack.update!(birthdate: 40.years.ago)
    @zoe.update!(pref_age_max: 30)

    assert_not_includes RecommendationService.new(@zoe).queue, @jack.id
  end

  test "queue excludes already-swiped users" do
    Swipe.create!(liker: @zoe, target: @jack, action: :pass)

    assert_not_includes RecommendationService.new(@zoe).queue, @jack.id
  end

  test "queue excludes blocked users" do
    Block.create!(blocker: @zoe, blocked: @jack)

    assert_not_includes RecommendationService.new(@zoe).queue, @jack.id
  end

  test "queue is a stable daily snapshot (cache hit keeps order)" do
    service = RecommendationService.new(@zoe)

    assert_equal service.queue, service.queue
  end

  test "queue is regenerated on a new day" do
    service = RecommendationService.new(@zoe)
    old_key = service.send(:queue_key)
    service.queue

    travel_to 1.day.from_now do
      new_service = RecommendationService.new(@zoe)
      assert_not_equal old_key, new_service.send(:queue_key)
      assert_includes new_service.queue, @jack.id
    end
  end

  test "consume! removes a candidate from the queue" do
    service = RecommendationService.new(@zoe)
    assert_includes service.queue, @jack.id

    assert service.consume!(@jack.id)
    assert_not_includes RecommendationService.new(@zoe).queue, @jack.id
  end

  test "consume! is idempotent for unknown ids" do
    service = RecommendationService.new(@zoe)
    before = service.queue

    refute service.consume!(-999)
    assert_equal before, RecommendationService.new(@zoe).queue
  end

  test "next_candidate returns the head of the queue" do
    service = RecommendationService.new(@zoe)

    assert_equal service.queue.first, service.next_candidate.id
  end

  test "daily quota counts swipes and tracks remaining" do
    service = RecommendationService.new(@zoe)
    assert_equal RecommendationService::DAILY_LIMIT, service.remaining_today
    assert_not service.exhausted?

    Swipe.create!(liker: @zoe, target: @jack, action: :like)
    assert_equal RecommendationService::DAILY_LIMIT - 1, service.remaining_today
  end

  test "exhausted when quota consumed even if queue has candidates" do
    service = RecommendationService.new(@zoe)
    assert_includes service.queue, @jack.id

    RecommendationService::DAILY_LIMIT.times do |i|
      target = User.create!(phone: "1390000000#{i}", nickname: "x#{i}", gender: :male,
                            birthdate: 25.years.ago, verification_level: :id_verified)
      Swipe.create!(liker: @zoe, target: target, action: :pass)
    end

    assert service.exhausted?
  end
end
