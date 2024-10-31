class Routine < ApplicationRecord
  belongs_to :user
  has_many :tasks, -> { order(position: :asc) }, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :liked_users, through: :likes, source: :user

  validates :title, presence: true, length: { maximum: 50 }
  validates :description, length: { maximum: 500 }

  enum notification: { no: 0, line: 1 }

  scope :posted,   ->           { where(is_posted: true) }
  scope :unposted, ->           { where(is_posted: false) }
  scope :my_post,  ->(user_id)  { where(user_id: user_id) }
  scope :official, ->           { joins(:user).where(users: { role: 'admin' }) }
  scope :general,  ->           { joins(:user).where(users: { role: 'general' }) }
  scope :liked,    ->(user_id)  { joins(:likes).where(likes: { user_id: user_id }) }

  # ルーティンをコピーする際、ルーティン情報をリセットする処理
  def reset_status
    self.is_active       = false
    self.is_posted       = false
    self.copied_count    = 0
    self.completed_count = 0
    self.notification    = 'no'
    self
  end

  def total_estimated_time
    result          = second_to_time_string(all_task_estimated_time)
    result[:hour]   = "0#{result[:hour]}" if result[:hour] < 10
    result[:minute] = "0#{result[:minute]}" if result[:minute] < 10
    result[:second] = "0#{result[:second]}" if result[:second] < 10
    result
  end

  # 検索処理：routineタイトルと説明文で部分検索
  def self.search(user_word)
    return all unless user_word

    user_words = user_word.split(' ')

    search_query = user_words.map{ '(routines.title LIKE ? OR routines.description LIKE ?)' }.join(' AND ')
    like_values = []
    user_words.each do |word|
      2.times{ like_values << "%#{word}%" }
    end
    
    where(search_query, *like_values)
  end

  # 絞り込み処理
  # 公式のみ、一般のみ、お気に入りのみ
  def self.custom_filter(filter_target, login_user_id)
    return all if filter_target.blank?
    
    case filter_target
    when 'liked'
      liked(login_user_id)
    when 'official'
      official
    when 'general'
      general
    when 'my_post'
      my_post(login_user_id)
    when 'posted'
      posted
    when 'unposted'
      unposted
    end
  end
  
  # 投稿の並べ替え処理
  def self.sort_posted(column, direction)
    column = "posted_at" if column.blank? 
    direction = "desc" if direction.blank? 
    
    order_by(column, direction)
  end

  # ルーティン一覧の並べ替え
  def self.sort_routine(column, direction)
    column = "created_at" if column.blank? 
    direction = "desc" if direction.blank? 

    order_by(column, direction)
  end

  private

  def second_to_time_string(time_in_second)
    hour = time_in_second / 3600
    time_in_second -= hour * 3600

    minute = time_in_second / 60
    time_in_second -= minute * 60

    second = time_in_second

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

  def self.order_by(column, direction)
    column_sym = column.to_sym
    direction_sym = direction.to_sym

    order(column_sym => direction_sym)
  end
end
