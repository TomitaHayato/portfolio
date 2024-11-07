# 外部で必要な処理
  # ページに遷移
RSpec.shared_examples 'ログイン前Header/Footerのテスト' do

  describe 'ヘッダー' do
    it 'before-login-headerが表示されている' do
      before_login_header_check
    end

    it 'ロゴをクリックでroot_pathに遷移' do
      check_bl_header_root_path
    end

    it 'ログインページに遷移できる' do
      check_bl_header_login_path
    end

    it 'ユーザー新規登録ページに遷移できる' do
      check_bl_header_new_user_path
    end

    it 'お試しログインできる' do
      check_bl_header_guest_login_path
    end
  end

  describe 'フッター' do
    it 'フッターが表示されている' do
      footer_check
    end

    it '利用規約ページに遷移できる' do
      check_footer_terms_path
    end

    it 'プライバシーポリシーページに遷移できる' do
      check_footer_policy_path
    end
  end
end