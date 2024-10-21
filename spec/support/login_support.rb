module LoginSupport
  def login_as(user)
    visit login_path

    fill_in 'email', with: user.email
    fill_in 'password', with: 'password'
    find('input[type="submit"]').click

    sleep 0.15
  end
end
