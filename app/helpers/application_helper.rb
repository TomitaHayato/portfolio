module ApplicationHelper
  def flash_type_class(type)
    case type.to_s
    when "notice" then "bg-green-400"
    when "alert" then "bg-red-400"
    else "bg-yellow-300"
    end
  end
end
