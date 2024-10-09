# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

tag_names_list = ['運動・健康', '美容', '趣味', '学習', '仕事・タスク', '自己投資', '日課']
if Tag.all.size == 0
  tag_names_list.each do |tag_name|
    Tag.create!(
      name: tag_name
    )
  end
end

if Reward.all.size == 0
  Reward.create!(
    name: "はじまりの一歩！",
    condition: "completed_routine_1?",
    description: "ルーティンを1回クリアする"
  )

  Reward.create!(
    name: "小さな達成者",
    condition: "completed_routines_3?",
    description: "ルーティンを3回クリアする"
  )

  Reward.create!(
    name: "若葉の成長",
    condition: "get_experiences_10?",
    description: "経験値を10獲得する"
  )

  Reward.create!(
    name: "朝の森の案内人",
    condition: "post_routine_1?",
    description: "ルーティンを1つ投稿する"
  )
end