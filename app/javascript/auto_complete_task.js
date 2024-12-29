// フォームの下にp要素を追加する処理
function appendOption(optionsZone, optionText) {
  let optionElement = document.createElement('p');
  optionElement.textContent = optionText;
  optionElement.className   = "text-start py-1 px-3 border rounded-lg hover:bg-blue-300";
  optionsZone.appendChild(optionElement);
}

// フォームDOMが置き換えられているか確認する処理
function isFormsChanged(titleForms) {
  const titleFormsNow = document.querySelectorAll('input[name="task[title]"]'); // 改めてtitleFormをすべて取得
  let   changedForms  = false;                                                  // formのDOMが変化している場合、変化後のDOMを返す

  // 長さが異なる場合、trueを返す
  if (titleForms.length !== titleFormsNow.length) {
    changedForms = titleFormsNow;

  } else {
    // 1つずつ要素を確認し、異なる要素があった場合は true を返す
    for (let i = 0; i < titleFormsNow.length; i++) {
      if (titleForms[i] !== titleFormsNow[i]) { 
        changedForms = titleFormsNow;
        break;
       }
    }
  }
  
  return changedForms;
}

// オートコンプリートを表示する処理
function taskTitleAutoComplete(titleForms) {
  const titleOptions = document.querySelectorAll('#all-task-names option');    // セレクトボックス内のoption要素をすべて取得

  if (titleOptions?.length === 0) return;

  // 各タイトルフォームに対してイベントリスナーを設定
  for (let titleForm of titleForms) {
    let formParent = titleForm.parentElement;
    
    // バリデーションエラーの場合、'field_with_errors'クラスのdivに囲まれるので、その親要素を取得する
    if (formParent.classList.contains('field_with_errors')) {
      formParent = formParent.parentElement;
    }

    const taskId      = formParent.id;
    const optionsZone = formParent.querySelector(`#task-title-options-zone-${taskId}`);
    
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
}

document.addEventListener('turbo:load', function(e) {
  const currentPath = window.location.pathname; //現在のパス名
  let titleForms = document.querySelectorAll('input[name="task[title]"]'); // Taskモデルのtitleフォームをすべて取得
  
  if (titleForms.length === 0) return;
  if (currentPath === '/routines') return;

  taskTitleAutoComplete(titleForms);
  
  // フォームDOMを監視し、変化があれば再度taskTitleAutoComplete();を実行する
  setInterval(function() {
    const newTitleForms = isFormsChanged(titleForms);
    if (newTitleForms ) {
      titleForms = newTitleForms;
      console.log("titleFormsが更新されました");
      taskTitleAutoComplete(titleForms);
    }
  }, 1000);
});
