# 兴趣标签（幂等）
INTERESTS = %w[
  旅行 美食 音乐 电影 运动 健身 阅读 摄影 宠物 咖啡
  游戏 桌游 露营 滑雪 潜水 骑行 烘焙 动漫 追剧 剧本杀
  徒步 登山 游泳 羽毛球 艺术 手作 直播 科技
].freeze

INTERESTS.each { |name| Interest.find_or_create_by!(name: name) }

puts "Seeded #{Interest.count} interests"
