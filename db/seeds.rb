# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

# タグ追加
tag_names_list = %w[運動・健康 美容 趣味 学習 仕事・タスク 自己投資 日課]

tag_names_list.each do |tag_name|
  Tag.find_or_create_by!(
    name: tag_name
  )
end

# 称号追加
Reward.find_or_create_by!(
  name: "はじまりの一歩！",
  condition: "completed_routine_1?",
  description: "ルーティンを1回クリアする"
)

Reward.find_or_create_by!(
  name: "小さな達成者",
  condition: "completed_routines_3?",
  description: "ルーティンを3回クリアする"
)

Reward.find_or_create_by!(
  name: "若葉の成長",
  condition: "get_experiences_10?",
  description: "経験値を10獲得する"
)

Reward.find_or_create_by!(
  name: "朝の森の案内人",
  condition: "post_routine_1?",
  description: "ルーティンを1つ投稿する"
)

Reward.find_or_create_by!(
  name: "未来の賢者",
  condition: "level_5?",
  description: "レベル5以上に達する"
)

Reward.find_or_create_by!(
  name: "朝の英雄",
  condition: "level_10?",
  description: "レベル10以上に達する"
)

Reward.find_or_create_by!(
  name: "コツコツマスター",
  condition: "better_myself_exp_10?",
  description: "自己投資の経験値を合計10以上獲得する"
)

Reward.find_or_create_by!(
  name: "朝の冒険家",
  condition: "completed_routines_10?",
  description: "ルーティンを10回クリアする"
)

Reward.find_or_create_by!(
  name: "幸運の猫大福",
  condition: "completed_routines_30?",
  description: "ルーティンを30回クリアする"
)
