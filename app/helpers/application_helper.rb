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
end
