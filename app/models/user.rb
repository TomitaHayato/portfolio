# rubocop:disable Metrics/ClassLength:

class User < ApplicationRecord
  mount_uploader :avatar, AvatarUploader

  authenticates_with_sorcery!

  has_many   :routines               , dependent: :destroy
  has_many   :user_tag_experiences   , dependent: :destroy
  has_many   :tags                   , through:   :user_tag_experiences
  has_many   :likes                  , dependent: :destroy
  has_many   :liked_routines         , through:   :likes, source: :routine
  has_many   :authentications        , dependent: :destroy
  has_many   :user_rewards           , dependent: :destroy
  has_many   :rewards                , through:   :user_rewards
  has_many   :achieve_records        , dependent: :destroy
  has_one    :quick_routine_template , dependent: :destroy
  belongs_to :feature_reward         , class_name: 'Reward', optional: true, inverse_of: 'featuring_users'

  accepts_nested_attributes_for :authentications

  validates :password,              length: { minimum: 8 }, if: -> { new_record? || changes[:crypted_password] }
  validates :password,              confirmation: true    , if: -> { new_record? || changes[:crypted_password] }
  validates :password_confirmation, presence:     true    , if: -> { new_record? || changes[:crypted_password] }
  validates :name,                  presence:     true    , length:     { maximum: 25 }
  validates :email,                 presence:     true    , uniqueness: true
  validates :reset_password_token,  uniqueness:   true    , allow_nil:  true

  enum role:         { admin: 0, general: 1, guest: 2 }
  enum notification: { off:   0, line:    1, email: 2 }

  def add_complete_routines_count
    self.complete_routines_count += 1
    save!
  end

  # 登録時に簡単なルーティンを作成する
  def make_first_routine
    routine_params = {
      title:       "#{name}さんのルーティン",
      description: '「編集」からタスクの追加・編集をしましょう！',
      is_active:   true
    }

    new_routine = routines.create!(routine_params)
    new_routine.make_first_task
  end

  # 取得していない称号の条件を1つ1つ確認し、条件を満たしていれば取得する処理
  def reward_get_check
    rewards_change_flag = false
    locked_rewards      = Reward.not_for_user(self) # レシーバが取得していない報酬データを取得
    # 条件達成? => 獲得
    locked_rewards.each do |reward|
      if reward_achieve?(reward)
        rewards << reward
        rewards_change_flag = true
      end
    end

    rewards_change_flag
  end

  # 経験値に応じて、レベルアップを行う
  def level_up_check
    level_up_flag = false # レベルアップしたかどうかを管理
    total_exp     = user_tag_experiences.total_experience_points

    while require_level_up?(total_exp)
      level_up
      level_up_flag = true
    end

    level_up_flag
  end

  # 次のレベルまでに必要な経験値
  def exp_to_next_level
    cal_exp_to_level_up - user_tag_experiences.total_experience_points
  end

  # exp_log = { "tag_id": exp, ... }
  def get_experiences(exp_log)
    exp_log.each do |tag_id, exp|
      user_tag_experiences.create!(
        tag_id:           tag_id.to_i,
        experience_point: exp
      )
    end
  end

  # lineアカウントと連携しているか
  def link_line?
    !authentications.where(provider: 'line').empty?
  end

  private

  #  --- Level UP ---
  # レベルアップするかどうかを判定
  def require_level_up?(total_exp)
    exp_to_level_up = cal_exp_to_level_up

    total_exp >= exp_to_level_up
  end

  # 次のレベルアップまでに必要なtotal経験値を計算
  # 式: 現在のレベルまでに必要だった経験値 + (現在レベル×5)
  def cal_exp_to_level_up
    exp_to_now_level  = cal_exp_to_now_level

    exp_to_now_level + (level * 5)
  end

  # レベル1から現在のレベルに達するまでに必要だった経験値
  def cal_exp_to_now_level
    level * (level - 1) * 5 / 2 # (1..level).sum { |level_now| (level_now - 1) * 5 }を数列の和の公式で展開
  end

  def level_up
    self.level += 1
    save!
  end

  # 称号獲得処理
  def reward_achieve?(reward)
    condition = reward.condition
    send(condition.to_sym)
  end

  # --- 称号の条件 ---
  def completed_routine_1?
    complete_routines_count >= 1
  end

  def completed_routines_3?
    complete_routines_count >= 3
  end

  def completed_routines_10?
    complete_routines_count >= 10
  end

  def completed_routines_30?
    complete_routines_count >= 30
  end

  # rubocop:disable Naming/AccessorMethodName:
  def get_experiences_10?
    user_tag_experiences.total_experience_points >= 10
  end

  # rubocop:enable Naming/AccessorMethodName:
  def better_myself_exp_10?
    Tag.find_by(name: '自己投資').user_tag_experiences.where(user_id: id).total_experience_points >= 10
  end

  def post_routine_1?
    routines.posted.size >= 1
  end

  def level_5?
    level >= 5
  end

  def level_10?
    level >= 10
  end
end

# rubocop:enable Metrics/ClassLength:
