class Routines::PostsController < ApplicationController
  before_action :set_order_query, only: %i[index]

  def index
    @user_words = params[:user_words]
    @routines = Routine.search(@user_words).includes(:tasks, :user).posted.sort_posted(@column, @direction).page(params[:page])
    @liked_routine_ids = current_user.liked_routine_ids
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

  def set_order_query
    @column = params[:column]
    @direction = params[:direction]
    @order_list = [['投稿日', nil], ['コピー数', 'copied_count']]
  end
end
