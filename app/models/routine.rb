# rubocop:disable Metrics/ClassLength:

class Routine < ApplicationRecord
  belongs_to :user
  has_many   :tasks, -> { order(position: :asc) }, dependent: :destroy, inverse_of: 'routine'
  has_many   :likes                              , dependent: :destroy
  has_many   :liked_users                        , through:   :likes  , source: :user

  validates :title      , length: { maximum: 25  }, presence: true
  validates :description, length: { maximum: 500 }

  scope :posted,   ->           { where(is_posted: true)  }
  scope :unposted, ->           { where(is_posted: false) }
  scope :my_post,  ->(user_id)  { where(user_id:) }
  scope :official, ->           { joins(:user).where(users: { role: 'admin' }) }
  scope :general,  ->           { joins(:user).where(users: { role: 'general' }) }
  scope :liked,    ->(user_id)  { joins(:likes).where(likes: { user_id: }) }

  def make_first_task
    task = tasks.create!(title: '水を飲む')
    tag  = Tag.find_by(name: '日課')
    task.tags << tag

    task
  end

  def copy(user)
    routine_dup = dup.reset_status
    routine_dup.user = user
    routine_dup.save!
    routine_dup
  end

  # TODO: テスト追加
  # レシーバに属するタスクのコピーをroutine_dupに保存
  def copy_tasks(routine_dup)
    tasks.each do |task_origin|
      # Taskのコピーを作成
      task_dup = task_origin.dup
      task_dup.update!(routine_id: routine_dup.id)
      # task_originに紐づいたtagをtask_dupにも紐付ける
      task_origin.copy_tags(task_dup)
    end
  end

  # ルーティンをコピーする際、ルーティン情報をリセットする処理
  def reset_status
    self.is_active       = false
    self.is_posted       = false
    self.copied_count    = 0
    self.completed_count = 0
    self
  end

  # クイック作成
  def self.quick_build(template)
    new(
      title:       template.title,
      description: template.description,
      start_time:  template.start_time
    )
  end

  def total_estimated_time
    result          = second_to_time_string(all_task_estimated_time)
    result[:hour]   = "0#{result[:hour]}"   if result[:hour]   < 10
    result[:minute] = "0#{result[:minute]}" if result[:minute] < 10
    result[:second] = "0#{result[:second]}" if result[:second] < 10
    result
  end

  # 検索処理：routineタイトルと説明文で部分検索
  def self.search(user_word)
    return all unless user_word

    user_words   = user_word.split
    search_query = user_words.map { '(routines.title LIKE ? OR routines.description LIKE ?)' }.join(' AND ')
    like_values  = []
    user_words.each do |word|
      2.times { like_values << "%#{word}%" }
    end

    where(search_query, *like_values)
  end

  # 絞り込み処理
  # 公式のみ、一般のみ、お気に入りのみ
  def self.custom_filter(filter_target, login_user_id)
    return all if filter_target.blank?

    case filter_target
    when 'liked'    then liked(login_user_id)
    when 'my_post'  then my_post(login_user_id)
    when 'official' then official
    when 'general'  then general
    when 'posted'   then posted
    when 'unposted' then unposted
    else
      all
    end
  end

  def copy_count
    self.copied_count += 1
    save!
  end

  def complete_count
    self.completed_count += 1
    save!
  end

  # 投稿の並べ替え処理
  def self.sort_posted(column, direction)
    column    = 'posted_at' if column.blank?
    direction = 'desc'      if direction.blank?

    order_by(column, direction)
  end

  # ルーティン一覧の並べ替え
  def self.sort_routine(column, direction)
    column    = 'created_at' if column.blank?
    direction = 'desc'       if direction.blank?

    order_by(column, direction)
  end

  def self.order_by(column, direction)
    column_sym    = column.to_sym
    direction_sym = direction.to_sym

    order(column_sym => direction_sym)
  end

  private

  def second_to_time_string(time_in_second)
    hour            = time_in_second / 3600
    time_in_second -= hour * 3600

    minute          = time_in_second / 60
    time_in_second -= minute * 60

    second          = time_in_second

    { hour:, minute:, second: }
  end

  def all_task_estimated_time
    total_estimated_time_in_second = 0
    if tasks.present?
      tasks.each do |task|
        total_estimated_time_in_second += task.estimated_time_in_second
      end
    end
    total_estimated_time_in_second
  end
end

# rubocop:enable Metrics/ClassLength:
