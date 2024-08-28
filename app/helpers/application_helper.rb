module ApplicationHelper
  def flash_type_class(type)
    case type.to_s
    when "notice" then "bg-green-400"
    when "alert" then "bg-red-400"
    else "bg-yellow-300"
    end
  end

  def bg_image_class
   current_user ? "min-h-screen bg-repeat-y bg-[url('morning_phone.jpg')]  lg:bg-[url('morning_pc.jpg')]" : ""
  end 
end
