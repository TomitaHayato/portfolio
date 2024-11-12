module FooterSupport
  def footer_check
    expect(page).to have_selector('footer')
  end

  def check_footer_policy_path
    footer_page_trans_test('プライバシーポリシー', policy_path)
  end

  def check_footer_terms_path
    footer_page_trans_test('利用規約', terms_path)
  end

  private

  # [リンクをクリック => ページ遷移できたか]をテストするコード
  def footer_page_trans_test(link_text, destination_path)
    footer_container = find('footer')
    footer_container.find('a', text: link_text).click

    expect(page).to have_current_path(destination_path)
  end
end