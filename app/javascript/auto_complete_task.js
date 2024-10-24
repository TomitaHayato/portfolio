document.addEventListener('turbo:load', function(event) {
  const titleOptions = document.querySelectorAll('#all-task-names option');    // セレクトボックス内のoption要素をすべて取得
  const titleForms   = document.querySelectorAll('input[name="task[title]"]'); // Taskモデルのtitleフォームをすべて取得

  if (!titleOptions) return;

  // フォームの下にp要素を追加する
  function appendOption(optionsZone, optionText) {
    let optionElement = document.createElement('p');

    optionElement.textContent = optionText;
    optionElement.className   = "text-start py-1 px-3 border rounded-lg hover:bg-blue-300";

    optionsZone.appendChild(optionElement);
  }

  // 各タイトルフォームに対してイベントリスナーを設定
  for (let titleForm of titleForms) {
    const eventParent = titleForm.parentElement;
    const taskId      = eventParent.id;
    const optionsZone = eventParent.querySelector(`#task-title-options-zone-${taskId}`);
    
    // フォームの値が変更された時、入力値の候補を表示する
    titleForm.addEventListener('input', function(event) {
      const userWords   = event.target.value;

      // optionsZoneの子要素をリセットする
      optionsZone.innerHTML = '';

      // タイトル候補を取得し、入力値を含む候補名をもつpタグをoptionsZoneに追加する
      for (let titleOption of titleOptions) {
        if (titleOption.textContent.includes(userWords)) {
          appendOption(optionsZone, titleOption.textContent);
        }
      }
    });

    // 追加された候補がクリックされた => そのテキストをフォームのvalueにする
    optionsZone.addEventListener('click', function(event) {
      if (event.target.tagName === 'P') {
        titleForm.value = event.target.textContent;
      }
      optionsZone.innerHTML = '';
    });

    // フォームからFocusを外した際、optionsZoneを非表示にする
    titleForm.addEventListener('blur', function(event) {
      setTimeout(
        function() {
          optionsZone.classList.add('hidden');
        },
        200
      );
    });

    // フォームがフォーカスされたとき、optionsZoneが非表示を解除する+フォームに何も入力されていなければ全候補を表示する
    titleForm.addEventListener('focus', function(event) {

      optionsZone.classList.remove('hidden');
      
      if (titleForm.value === '' && optionsZone.children.length === 0) {
        for (let titleOption of titleOptions) { appendOption(optionsZone, titleOption.textContent); }
      }
    });
  }
});