class TopPagesController < ApplicationController
  skip_before_action :require_login
  before_action :login_check

  def index; end

  private

  def login_check
    redirect_to my_pages_path if current_user
  end
end
