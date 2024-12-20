source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.3.4"

# 警告メッセージを消す
gem 'mutex_m'
gem 'drb'
#9 tailswindを導入
gem "cssbundling-rails"
#16 ユーザー登録機能
gem "sorcery"
#47 タスクの並べ替え機能
gem "acts_as_list"
# ページネーション
gem "kaminari"
# 日本語化
gem 'rails-i18n'
# LINE-bot作成
gem 'line-bot-api'
# 環境ごとの設定
gem 'config'
# redisをrailsアプリで操作
gem 'redis'
# バックグラウンド処理
gem 'sidekiq'
gem 'sidekiq-scheduler'
# s3と接続する
gem "aws-sdk-s3"
gem 'fog-aws'
# 画像ファイル
gem 'carrierwave', '~> 3.0'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.0.8", ">= 7.0.8.4"

# The original asset pipeline for Rails [https://github.com/rails/sprockets-rails]
gem "sprockets-rails"

# Use postgresql as the database for Active Record
gem "pg", "~> 1.1"

# Use the Puma web server [https://github.com/puma/puma]
gem "puma", "~> 5.0"

# Bundle and transpile JavaScript [https://github.com/rails/jsbundling-rails]
gem "jsbundling-rails"

# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"

# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Redis adapter to run Action Cable in production
# gem "redis", "~> 4.0"

# Use Kredis to get higher-level data types in Redis [https://github.com/rails/kredis]
# gem "kredis"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ mingw mswin x64_mingw jruby ]

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Use Sass to process CSS
# gem "sassc-rails"

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem "image_processing", "~> 1.2"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  # rubocop: Lintチェック
  gem "rubocop", require: false
  gem 'rubocop-rails', require: false
  gem 'rubocop-performance', require: false
  # rspec: テスト用
  gem 'rspec-rails', '~> 6.1.0'
  gem 'factory_bot_rails'
  gem "capybara"
  gem "selenium-webdriver"
  # テスト用のダミーデータを作成
  gem 'faker'
  gem 'simplecov', require: false
end

group :development do
  # パスワードリセット
  gem 'letter_opener_web', '~> 3.0'
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
  # rspec
  gem 'spring-commands-rspec'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  # gem "rack-mini-profiler"

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  # gem "spring"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
end
