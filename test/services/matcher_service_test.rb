require "test_helper"

class MatcherServiceTest < ActiveSupport::TestCase
  setup do
    @zoe = users(:one)   # female
    @jack = users(:two)  # male
  end

  test "like without reciprocal does not create a match" do
    assert_difference("Match.count", 0) do
      assert_not MatcherService.like(@zoe, @jack)
    end
    assert @zoe.swipes.exists?(target: @jack, action: :like)
  end

  test "mutual likes create a match" do
    MatcherService.like(@jack, @zoe)

    assert_difference("Match.count", 1) do
      assert MatcherService.like(@zoe, @jack)
    end
    assert @zoe.matches.count == 1
  end

  test "like is idempotent" do
    MatcherService.like(@zoe, @jack)
    assert_no_difference("Swipe.count") { MatcherService.like(@zoe, @jack) }
  end

  test "cannot match with self" do
    assert_difference("Match.count", 0) { MatcherService.like(@zoe, @zoe) }
  end

  test "pass records a swipe without matching" do
    MatcherService.pass(@zoe, @jack)
    assert @zoe.swipes.exists?(target: @jack, action: :pass)
    assert_equal 0, Match.count
  end

  test "match other_user returns the counterpart" do
    match = MatcherService.create_match(@zoe, @jack)
    assert_equal @jack, match.other_user(@zoe)
    assert_equal @zoe, match.other_user(@jack)
  end
end
