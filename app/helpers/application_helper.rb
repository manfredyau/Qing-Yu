module ApplicationHelper
  # 统一表单输入框样式
  def field_class(has_error = false)
    base = "mt-1.5 block w-full rounded-xl border px-4 py-3 text-base shadow-sm placeholder:text-gray-300 focus:outline-none focus:ring-2"
    if has_error
      "#{base} border-red-300 focus:border-red-500 focus:ring-red-100"
    else
      "#{base} border-gray-200 focus:border-teal-500 focus:ring-teal-200"
    end
  end

  # 后台状态徽章配色
  def status_badge(status)
    {
      "pending" => "bg-amber-50 text-amber-600",
      "verified" => "bg-emerald-50 text-emerald-600",
      "approved" => "bg-emerald-50 text-emerald-600",
      "rejected" => "bg-red-50 text-red-600",
      "id_verified" => "bg-teal-50 text-teal-600",
      "fully_verified" => "bg-teal-600 text-white",
      "unverified" => "bg-gray-100 text-gray-500"
    }[status.to_s] || "bg-gray-100 text-gray-500"
  end

  # 字段级错误提示（配合 form-errors 控制器滚动定位）
  def error_for(record, attribute)
    record.errors[attribute].first
  end

  # 资料缺项 → 编辑页对应区块锚点（缺项可点击跳转，配合自动滚动）
  def section_id_for_part(part)
    {
      "昵称" => "section-basic", "生日" => "section-basic", "性别" => "section-basic",
      "城市" => "section-basic", "照片" => "section-photos", "兴趣标签" => "section-interests"
    }[part]
  end
end
