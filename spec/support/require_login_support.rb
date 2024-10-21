module RequireLoginSupport
  def login_failed_check(path)
    visit path
    expect(page).to have_current_path(login_path)
    expect(page).to have_content('ログインしてください')
  end
end
