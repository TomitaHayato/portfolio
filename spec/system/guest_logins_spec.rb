require 'rails_helper'

RSpec.describe "GuestLogins", type: :system do
  before do
    visit root_path
    click_on 'お試し'
    sleep 0.25

    @user = User.last
    p "ユーザーは#{@user.name}です"
  end

  it 'ゲストログインできる' do
    expect(page).to have_current_path(my_pages_path)
    expect(page).to have_content('ゲストログインしました。')
  end

  describe 'guest_blockメソッド' do
    it 'ユーザー編集できない' do
      click_on 'user-icon-btn'
      expect(page).to have_current_path(user_path(@user))

      click_on "プロフィールを編集"
      expect(page).to have_current_path(user_path(@user))
      expect(page).to have_content('ゲストユーザー様はご利用できません')
    end

    it 'ルーティンを投稿できない' do
      routine = create(:routine, user: @user)

      visit routines_path
      expect(page).to have_current_path(routines_path)

      click_on "routine-post-btn-#{routine.id}"
      expect(page).to have_current_path(routines_path)
      expect(page).to have_content('ゲストユーザー様はご利用できません')
      expect(page).to have_selector("#routine-post-btn-#{routine.id}")
    end

    it '投稿をコピーできない' do
      posted_routine = create(:routine, is_posted: true)

      visit routines_posts_path
      expect(page).to have_current_path(routines_posts_path)

      click_on "copy-btn-#{posted_routine.id}"
      expect(page).to have_current_path(routines_posts_path)
      expect(page).to have_content('ゲストユーザー様はご利用できません')
    end
  end

  describe 'ログアウト処理' do
    it 'ログアウトすると、ユーザー情報がDBから削除される' do
      click_on 'ログアウト'
      sleep 0.25

      last_user = User.where(id: @user.id) 
      expect(last_user).to eq []
    end
  end
end
