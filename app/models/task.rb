class Task < ApplicationRecord
  belongs_to :routine
  has_many   :task_tags, dependent: :destroy
  has_many   :tags     , through:   :task_tags

  acts_as_list scope: :routine

  validates :title,
            presence: true,
            length: { maximum: 25 }
  validates :estimated_time_in_second,
            presence: true,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 1,
              message: 'は1秒以上で設定してください'
            }

  def estimated_time
    result          = second_to_time_string(estimated_time_in_second)
    result[:hour]   = "0#{result[:hour]}"   if result[:hour]   < 10
    result[:minute] = "0#{result[:minute]}" if result[:minute] < 10
    result[:second] = "0#{result[:second]}" if result[:second] < 10
    result
  end

  # 元々セットされていたが、フォームで選択されなかったタグを削除
  def delete_tags_from_task(tag_ids_param)
    tag_ids_param = [] if tag_ids_param.nil?
    tag_ids_param.map(&:to_i)

    tags.each { |tag| tags.destroy(tag) unless tag_ids.include?(tag) }
  end

  # フォームで新しく指定されたタグをタスクに追加する
  def put_tags_on_task(tag_ids_param)
    return if tag_ids_param.nil?

    tag_ids_param = tag_ids_param.map(&:to_i)

    tag_ids_param.each { |tag_id| tags << Tag.find(tag_id) unless tag_ids.include?(tag_id) }
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
end
