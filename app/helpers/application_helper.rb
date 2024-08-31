module ApplicationHelper
  def flash_type_class(type)
    case type.to_s
    when 'notice' then 'bg-green-400'
    when 'alert' then 'bg-red-400'
    else 'bg-yellow-300'
    end
  end

  def bg_image_class
    current_user ? "min-h-screen bg-repeat-y bg-[url('morning_phone.jpg')]  lg:bg-[url('morning_pc.jpg')]" : ''
  end

  def shallow_bg_class
    request.path == root_path ? 'pb-16 mt-12 sm:mt-16 md:mt-20 lg:mt-24' : 'pb-16 mt-12 sm:mt-16 md:mt-20 lg:mt-24 w-4/5 border h-full mx-auto bg-blue-100/80 min-h-screen'
  end
end
