# 轻遇 (Qingyu) 开发环境种子数据（幂等，可重复执行）
#   bin/rails db:seed

require "zlib"
require "stringio"

# ---- 工具：程序化生成纯色 PNG（避免演示照片依赖网络） ----
def solid_color_png(hex_color, size = 256)
  r, g, b = [ hex_color[1, 2], hex_color[3, 2], hex_color[5, 2] ].map { |h| h.to_i(16) }
  raw = +""
  (0...size).each do |_y|
    raw << "\x00"
    (0...size).each { raw << [ r, g, b ].pack("C3") }
  end
  chunk = lambda do |type, data|
    [ data.bytesize ].pack("N") + type + data + [ Zlib.crc32(type + data) ].pack("N")
  end
  ihdr = [ size, size, 8, 2, 0, 0, 0 ].pack("NNCCCCC")
  ("\x89PNG\r\n\x1a\n".b + chunk.call("IHDR", ihdr) + chunk.call("IDAT", Zlib::Deflate.deflate(raw)) + chunk.call("IEND", ""))
end

def attach_photo(user, hex_color, filename)
  photo = user.photos.create!(
    file: { io: StringIO.new(solid_color_png(hex_color)), filename: filename, content_type: "image/png" },
    status: :approved
  )
  photo
end

# ---- 兴趣标签 ----
INTERESTS = %w[
  旅行 美食 音乐 电影 运动 健身 阅读 摄影 宠物 咖啡
  游戏 桌游 露营 滑雪 潜水 骑行 烘焙 动漫 追剧 剧本杀
  徒步 登山 游泳 羽毛球 艺术 手作 直播 科技
].freeze
INTERESTS.each { |name| Interest.find_or_create_by!(name: name) }

# ---- 后台管理员（生产环境请修改密码） ----
AdminUser.find_or_create_by!(email_address: "admin@qingyu.local") do |admin|
  admin.name = "超级管理员"
  admin.password = "Qingyu@2026"
end

# ---- 演示用户 ----
# [手机号尾号, 昵称, 性别, 年龄, 城市, 学历, 职业, 简介, 主色, 标签]
DEMO_USERS = [
  [ "01", "林一", "female", 25, "北京", "bachelor", "产品经理", "喜欢咖啡和看展，期待真诚的关系", "#f472b6", %w[咖啡 艺术 旅行] ],
  [ "02", "陈默", "male",   28, "上海", "master",   "算法工程师", "周末爬山，平时写代码，寻一个同频的人", "#34d399", %w[徒步 科技 电影] ],
  [ "03", "苏晓", "female", 24, "杭州", "bachelor", "插画师", "养了一只橘猫，想把生活过得有趣一点", "#fbbf24", %w[宠物 手作 美食] ],
  [ "04", "周航", "male",   30, "深圳", "phd",      "研究员", "理性又浪漫，喜欢深夜聊电影", "#60a5fa", %w[电影 阅读 音乐] ],
  [ "05", "顾言", "female", 27, "成都", "bachelor", "设计师", "火锅与徒步都要，生活需要一点辣", "#a78bfa", %w[美食 徒步 摄影] ],
  [ "06", "沈括", "male",   26, "广州", "college",  "创业者", "在路上的创业者，寻找能聊得来的人", "#2dd4bf", %w[骑行 咖啡 音乐] ],
  [ "07", "许晴", "female", 29, "南京", "master",   "教师", "喜欢读诗和教书，温柔且坚定", "#fb7185", %w[阅读 音乐 烘焙] ],
  [ "08", "陆川", "male",   31, "武汉", "bachelor", "摄影师", "用镜头记录城市，也想记录你", "#f97316", %w[摄影 旅行 电影] ]
].freeze

# 程序化生成校验位合法的 18 位身份证号（GB 11643-1999）
ID_WEIGHTS = [ 7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2 ].freeze
ID_CODES = %w[1 0 X 9 8 7 6 5 4 3 2].freeze
def valid_id_number(seed)
  base = format("%017d", seed)
  sum = base.chars.each_with_index.sum { |c, i| c.to_i * ID_WEIGHTS[i] }
  base + ID_CODES[sum % 11]
end

DEMO_USERS.each_with_index do |(tail, nickname, gender, age, city, education, job, bio, color, tags), i|
  phone = "138000000#{tail}"
  user = User.find_or_initialize_by(phone: phone)
  user.assign_attributes(
    nickname: nickname, gender: gender, birthdate: (Date.current - age.years).to_date,
    city: city, education_level: education, job: job, bio: bio,
    verification_level: :fully_verified, verified_at: Time.current,
    pref_gender: (gender == "male" ? :female : :male), status: :active
  )
  user.save! if user.changed?

  # 兴趣
  user.interests = Interest.where(name: tags)

  # 照片（3 张同色系变体）
  if user.photos.count < 3
    3.times do |n|
      lighter = color
      attach_photo(user, lighter, "demo_#{i}_#{n}.png")
    end
    user.photos.approved.order(:id).first.update!(primary: true)
  end

  # 实名认证记录（演示 V2）
  next if user.identity_verifications.verified.exists?
  IdentityVerification.create!(
    user: user, full_name: nickname, id_number: valid_id_number(i + 1),
    status: :verified, verified_at: Time.current, provider: "mock"
  )
  EducationVerification.create!(
    user: user, verify_code: format("1%011d", i + 1), report_no: format("QY%014d", i),
    school: [ "北京大学", "清华大学", "浙江大学", "复旦大学" ][i % 4],
    degree: [ "本科", "硕士", "博士" ][i % 3],
    education_level: education, status: :verified, verified_at: Time.current, provider: "mock"
  )
end

# ---- 演示配对与消息（前两位用户） ----
zoe = User.find_by(phone: "13800000001")
mutual = User.find_by(phone: "13800000002")
if zoe && mutual && !Match.exists?(user_a_id: [ zoe.id, mutual.id ].min, user_b_id: [ zoe.id, mutual.id ].max)
  match = MatcherService.create_match(zoe, mutual)
  Message.create!(match: match, sender: zoe, body: "你好呀，看到你也喜欢爬山 ⛰️")
  Message.create!(match: match, sender: mutual, body: "哈喽！周末约一起去西山吗？")
end

puts "✅ Seeded: #{Interest.count} interests · #{AdminUser.count} admin · #{User.count} users · #{Match.count} matches"
