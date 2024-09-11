# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)

tag_names_list = ['運動・健康', '美容', '趣味', '学習', '仕事・タスク', '自己投資', '日課']
tag_names_list.each do |tag_name|
  Tag.create!(
    name: tag_name
  )
end
