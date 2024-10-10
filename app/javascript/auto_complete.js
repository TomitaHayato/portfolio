document.addEventListener('turbo:load', function(event) {
  const options = document.querySelectorAll('#selectable-options option');
  const optionsZone = document.getElementById('search-options');
  const searchForm = document.getElementById('user_words');

  // 検索フォームの真下にDOM要素を追加する
  function appendOption(optionText) {
    //検索候補を表示するpタグを作成
    let optionElement = document.createElement('p');
    
    optionElement.textContent = optionText;
    optionElement.className = 'search-option bg-white p-1 rounded-lg border hover:bg-blue-100/70 active:text-sm';
    optionsZone.appendChild(optionElement); // optionZone内にpタグを追加
  }

  if (!searchForm) return;

  //検索フォームにユーザーが入力したときに発火
  searchForm.addEventListener('input', function(event) {
    // まず、選択肢欄を空にする
    optionsZone.innerHTML = '';
    if (searchForm.value === '') return;

    // 検索ワード候補をHTMLに追加
    let user_word = searchForm.value
    for (let option of options) {
      if (option.textContent.includes(user_word)) { //　選択肢が検索ワードを含むかどうか
        appendOption(option.textContent); // 検索フォームの下に検索項目候補の要素を追加する
      }
    }

    optionsZone.addEventListener('click', function(event) {
      if (event.target.classList.contains('search-option')) {
        let optionWord = event.target.textContent;
        searchForm.value = optionWord;
        optionsZone.innerHTML = '';
      }
    });

  });

});
