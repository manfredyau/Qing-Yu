# 滑卡与配对服务
class MatcherService
  # 喜欢：记录滑动；若对方也已喜欢 → 创建配对，返回是否新配对
  def self.like(liker, target)
    Swipe.find_or_create_by!(liker: liker, target: target) { |s| s.action = :like }
    return false if liker == target
    return false unless Swipe.exists?(liker: target, target: liker, action: :like)

    create_match(liker, target)
    true
  end

  def self.pass(liker, target)
    Swipe.find_or_create_by!(liker: liker, target: target) { |s| s.action = :pass }
  end

  def self.create_match(user_a, user_b)
    a, b = [ user_a, user_b ].sort_by(&:id)
    match = Match.active.find_or_create_by!(user_a_id: a.id, user_b_id: b.id)
    MatchMembership.find_or_create_by!(match: match, user: a)
    MatchMembership.find_or_create_by!(match: match, user: b)
    match
  end
end
