module ApplicationHelper
  def flash_type_class(type)
    case type.to_s
    when 'notice' then 'bg-green-400'
    when 'alert' then 'bg-red-400'
    else 'bg-orange-400'
    end
  end

  # ----------- CSSクラスに関するヘルパー ---------------------------------------------
  def bg_image_class
    current_user ? "min-h-screen bg-repeat-y bg-[url('morning_phone.jpg')]  lg:bg-[url('morning_pc.jpg')]" : ''
  end

  # 表示されているページがトップページかどうかでクラスを変更する
  # 背景画像のデザインに関するクラス
  def shallow_bg_class
    case request.path
    when root_path, policy_path, terms_path
      return ''
    else
      return 'pb-16 pt-1 h-full mx-auto bg-green-50/90 min-h-screen w-11/12 sm:w-4/5'
    end
  end

  def task_arrange_class
    request.path == routines_path ? '' : 'hover:bg-amber-100'
  end

  def feature_icon_class(reward, feature_reward)
    return 'i-uiw-star-off text-gray-500' if feature_reward.nil?

    reward.id == feature_reward.id ? 'i-uiw-star-on text-red-500' : 'i-uiw-star-off text-gray-500'
  end
  # --------------------------------------------------------

  def task_form_id(task)
    task.id.nil? ? 'new' : "#{task.id}"
  end

  # ログインしているか否かでルートページへのパスを返す
  def root_page
    current_user ? my_pages_path : root_path
  end
end
