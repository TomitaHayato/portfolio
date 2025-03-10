module ApplicationHelper
  # ----------- CSSクラスに関するヘルパー ---------------------------------------------
  def flash_type_class(type)
    case type.to_s
    when 'notice' then 'bg-green-400'
    when 'alert'  then 'bg-red-400'
    else 'bg-sky-400'
    end
  end

  def flash_icon(type)
    case type.to_s
    when 'notice' then 'i-uiw-circle-check-o'
    else 'i-uiw-warning'
    end
  end

  def bg_image_class
    current_user ? "min-h-screen bg-repeat-y bg-[url('morning_phone.jpg')]  lg:bg-[url('morning_pc.jpg')]" : ''
  end

  # 表示されているページがトップページかどうかでクラスを変更する
  # 背景画像のデザインに関するクラス
  def shallow_bg_class
    case request.path
    when root_path, policy_path, terms_path
      ''
    else
      'pb-16 pt-1 h-full mx-auto bg-gradient-to-b from-teal-50 to-emerald-50/90 min-h-screen w-11/12 sm:w-4/5'
    end
  end

  def task_arrange_class
    request.path == routines_path ? '' : 'hover:bg-amber-100 tooltip tooltip-success'
  end
  # --------------------------------------------------------

  # Task作成・編集フォームに割り振るID
  def task_form_id(task)
    task.id.nil? ? 'new' : task.id.to_s
  end

  # ログインしているか否かでルートページへのパスを返す
  def root_page
    current_user ? my_pages_path : root_path
  end

  # 秒数をHH:MM:SS形式に変更
  def sec_to_hms(sec)
    hour, sec = sec.divmod(3600)
    min , sec = sec.divmod(60)

    hms  = []
    hms << "#{hour}時間" if hour.positive?
    hms << "#{min}分"    if  min.positive?
    hms << "#{sec}秒"

    hms.join(' ')
  end
end
