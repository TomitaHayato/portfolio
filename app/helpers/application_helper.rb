module ApplicationHelper
  def flash_type_class(type)
    case type.to_s
    when 'notice' then 'bg-green-400'
    when 'alert' then 'bg-red-400'
    else 'bg-orange-400'
    end
  end

  def bg_image_class
    current_user ? "min-h-screen bg-repeat-y bg-[url('morning_phone.jpg')]  lg:bg-[url('morning_pc.jpg')]" : ''
  end

  # 表示されているページがトップページかどうかでクラスを変更する
  # 背景画像のデザインに関するクラス
  def shallow_bg_class
    case request.path
    when root_path
      'pb-16 mt-12 sm:mt-14 md:mt-16'
    when policy_path, terms_path
      'mt-12 sm:mt-14 md:mt-16'
    else
      'pb-16 mt-12 sm:mt-14 md:mt-16 w-4/5 border h-full mx-auto bg-green-100/90 min-h-screen'
    end
  end

  def task_arrange_class
    request.path == routines_path ? '' : 'hover:bg-amber-100'
  end

  def task_form_id(task)
    task.id.nil? ? 'new' : "#{task.id}"
  end

  # ログインしているか否かでルートページへのパスを返す
  def root_page
    current_user ? my_pages_path : root_path
  end
end
