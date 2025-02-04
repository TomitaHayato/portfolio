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

  # rubocop:disable Rails/SkipsModelValidations
  # レシーバに紐づいたtagをtask_dupにも紐付ける
  def copy_tags(task_dup)
    return if tags.empty?

    TaskTag.insert_all(make_tasktag_copies_array(task_dup))
  end
  # rubocop:enable Rails/SkipsModelValidations

  def estimated_time
    result          = second_to_hms(estimated_time_in_second)
    result[:hour]   = "0#{result[:hour]}"   if result[:hour]   < 10
    result[:minute] = "0#{result[:minute]}" if result[:minute] < 10
    result[:second] = "0#{result[:second]}" if result[:second] < 10
    result
  end

  # 元々セットされていたが、フォームで選択されなかったタグを削除
  def delete_tags_from_task(tag_ids_params)
    tag_ids_params = [] if tag_ids_params.nil?

    tag_ids_params.map(&:to_i)

    tags.each { |tag| tags.destroy(tag) unless tag_ids.include?(tag) }
  end

  # フォームで新しく指定されたタグをタスクに追加する
  def put_tags_on_task(tag_ids_params)
    # フォームで指定されたタグがない => '日課'タグを設定してreturn
    if tag_ids_params.nil?
      daily_work_tag = Tag.find_by(name: '日課')
      tags << daily_work_tag unless tags.include?(daily_work_tag)
      return
    end

    tag_ids_params = tag_ids_params.map(&:to_i)
    tag_ids_params.each { |tag_id| tags << Tag.find(tag_id) unless tag_ids.include?(tag_id) }
  end

  private

  def second_to_hms(second)
    hour  , second = second.divmod(3600)
    minute, second = second.divmod(60)

    { hour:, minute:, second: }
  end

  # TaskTagsテーブルに保存する情報をもつ配列を作成する
  def make_tasktag_copies_array(task_dup)
    tag_ids.map do |tag_id|
      {
        tag_id:,
        task_id: task_dup.id
      }
    end
  end
end
