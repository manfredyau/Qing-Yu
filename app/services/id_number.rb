# 中国大陆居民身份证号（18 位）校验：GB 11643-1999 校验位算法
module IdNumber
  WEIGHTS = [ 7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 ].freeze
  CHECK_CODES = %w[1 0 X 9 8 7 6 5 4 3 2].freeze

  module_function

  def valid?(number)
    number = number.to_s.strip.upcase
    return false unless number.match?(/\A\d{17}[\dX]\z/)

    sum = number.chars.first(17).each_with_index.sum { |digit, index| digit.to_i * WEIGHTS[index] }
    CHECK_CODES[sum % 11] == number[-1]
  end

  # 脱敏：保留前 4 位与后 4 位
  def mask(number)
    number.to_s.strip.sub(/\A(.{4}).*(.{4})\z/, '\1**********\2')
  end
end
