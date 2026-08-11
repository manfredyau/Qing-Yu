module Verification
  module Education
    # Mock 服务商：模拟「教育部学籍/学历在线验证报告」核验
    #
    # 用户流程：学信网申请在线验证报告 → 获得 12 位在线验证码 + 16 位报告编号
    # 本服务商内置演示学籍库，格式校验按真实报告规则设计。
    class MockProvider
      # 演示学籍库：验证码 => [学校, 学历, education_level]
      SCHOOLS = {
        "100000000001" => [ "北京大学", "本科", User.education_levels[:bachelor] ],
        "200000000002" => [ "清华大学", "硕士", User.education_levels[:master] ],
        "300000000003" => [ "浙江大学", "博士", User.education_levels[:phd] ],
        "400000000004" => [ "复旦大学", "本科", User.education_levels[:bachelor] ],
        "500000000005" => [ "武汉大学", "本科", User.education_levels[:bachelor] ]
      }.freeze

      def verify(verify_code:, report_no:, **)
        return EducationProvider::Result.new(false, "在线验证码应为 12 位数字", nil) unless verify_code.to_s.match?(/\A\d{12}\z/)
        return EducationProvider::Result.new(false, "报告编号应为 16 位", nil) unless report_no.to_s.match?(/\A[A-Z0-9]{16}\z/i)

        school = SCHOOLS[verify_code.to_s]
        return EducationProvider::Result.new(false, "未查询到学籍信息，请核对验证码与报告编号", nil) unless school

        EducationProvider::Result.new(true, "学籍信息核验通过", {
          school: school[0], degree: school[1], education_level: school[2]
        })
      end
    end
  end
end
