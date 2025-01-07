class Routines::PostsController < ApplicationController
  before_action :set_order_query, only: %i[index]
  before_action :set_filter_target, only: %i[index]
  before_action :guest_block, only: %i[update]

  def index
    @user_words         = params[:user_words]
    @routines           = Routine.search(@user_words).custom_filter(@filter_target, current_user.id).includes({ tasks: :tags, user: :feature_reward }, :user).posted.sort_posted(@column, @direction).page(params[:page])
    @liked_routine_ids  = current_user.liked_routine_ids # お気に入りボタンの表示切り替えに使用
    @auto_complete_list = Routine.posted.make_routine_autocomplete_list
  end

  def update
    @routine = current_user.routines.find(params[:routine_id])
    if @routine.is_posted?
      @routine.update!(is_posted: false)
      flash.now[:notice] = 'ルーティンを非公開にしました'
    else
      @routine.update!(is_posted: true, posted_at: Time.current)
      flash.now[:notice] = 'ルーティンを投稿しました'
    end
  end

  private

  # rubocop:disable Style/WordArray
  def set_order_query
    @column     = params[:column]
    @direction  = params[:direction]
    @order_list = [
      ['投稿日'  , nil],
      ['コピー数', 'copied_count']
    ]
  end

  def set_filter_target
    @filter_target  = params[:filter_target]
    @filter_options = [
      ['すべて'       , nil],
      ['自分の投稿'   , 'my_post'],
      ['お気に入り'   , 'liked'],
      ['公式の投稿'   , 'official'],
      ['ユーザーの投稿', 'general']
    ]
  end
  # rubocop:enable Style/WordArray
end
