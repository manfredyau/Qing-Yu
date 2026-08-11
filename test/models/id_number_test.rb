require "test_helper"

class IdNumberTest < ActiveSupport::TestCase
  test "accepts a valid 18-digit ID number" do
    assert IdNumber.valid?("11010519491231002X")
  end

  test "generates a valid checksum number" do
    # 用算法自生成一个必然合法的号码
    base = "11010119900101001"
    weights = [ 7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 ]
    codes = %w[1 0 X 9 8 7 6 5 4 3 2]
    sum = base.chars.each_with_index.sum { |c, i| c.to_i * weights[i] }
    id = base + codes[sum % 11]
    assert IdNumber.valid?(id)
  end

  test "rejects wrong checksum" do
    assert_not IdNumber.valid?("110105194912310021")
  end

  test "rejects wrong length and non-numeric" do
    assert_not IdNumber.valid?("123")
    assert_not IdNumber.valid?("abcdefghijklmnopqrs")
  end

  test "masks middle digits" do
    assert_equal "1101**********002X", IdNumber.mask("11010519491231002X")
  end
end
