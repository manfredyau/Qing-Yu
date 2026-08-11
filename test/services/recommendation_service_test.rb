require "test_helper"

class RecommendationServiceTest < ActiveSupport::TestCase
  setup do
    @zoe = users(:one)  # female, pref male
    @jack = users(:two) # male

    @zoe.update!(pref_gender: :male)
    @zoe.update!(birthdate: 25.years.ago)
    @jack.update!(birthdate: 25.years.ago)
  end

  test "candidates require verified users with disclosed gender" do
    @jack.update!(verification_level: :id_verified)

    candidates = RecommendationService.new(@zoe).candidates
    assert_includes candidates, @jack
    assert_not_includes candidates, @zoe

    @jack.update!(gender: :undisclosed)
    assert_not_includes RecommendationService.new(@zoe).candidates, @jack
  end

  test "candidates respect preferred gender" do
    @jack.update!(verification_level: :id_verified)
    @zoe.update!(pref_gender: :female)

    assert_not_includes RecommendationService.new(@zoe).candidates, @jack
  end

  test "candidates respect age range" do
    @jack.update!(verification_level: :id_verified, birthdate: 40.years.ago)
    @zoe.update!(pref_age_max: 30)

    assert_not_includes RecommendationService.new(@zoe).candidates, @jack
  end

  test "candidates exclude already-swiped users" do
    @jack.update!(verification_level: :id_verified)
    Swipe.create!(liker: @zoe, target: @jack, action: :pass)

    assert_not_includes RecommendationService.new(@zoe).candidates, @jack
  end

  test "candidates exclude blocked users" do
    @jack.update!(verification_level: :id_verified)
    Block.create!(blocker: @zoe, blocked: @jack)

    assert_not_includes RecommendationService.new(@zoe).candidates, @jack
  end

  test "daily quota counts swipes and tracks remaining" do
    service = RecommendationService.new(@zoe)
    assert_equal RecommendationService::DAILY_LIMIT, service.remaining_today
    assert_not service.exhausted?

    Swipe.create!(liker: @zoe, target: @jack, action: :like)
    assert_equal RecommendationService::DAILY_LIMIT - 1, service.remaining_today
  end
end
