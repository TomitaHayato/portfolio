const changeInfoEdit = function() {
  const routineEditForm = document.querySelector('#routine-edit-form');
  const routineInfo     = document.querySelector('#routine-info');
  const cancelBtn       = document.querySelector('#edit-form-cancel-btn');
  const editBtn         = document.querySelector('#edit-icon-btn');

  const formToInfo = function() {
    if (routineEditForm.classList.contains('hidden')) return;
    
    routineEditForm.classList.add('hidden');
    routineInfo.classList.remove('hidden');
  }

  const infoToForm = function() {
    if (routineInfo.classList.contains('hidden')) return;

    routineInfo.classList.add('hidden');
    routineEditForm.classList.remove('hidden');
  }

  // キャンセル => フォームを隠して、Infoを表示
  cancelBtn.addEventListener('click', () => {
    formToInfo();
  });

  // 編集 => Infoを隠してフォームを表示
  editBtn.addEventListener('click', () => {
    infoToForm();
  });
}

document.addEventListener('turbo:load', function(event) {
  const routineShowPageId = document.querySelector('#routine-show-page');
  if(!routineShowPageId) return;

  changeInfoEdit();
});

//turbo_streamによる更新後にchangeInfoEditを実行。
document.addEventListener('turbo:before-stream-render', function(event) {
  const routineShowPageId = document.querySelector('#routine-show-page');
  if(!routineShowPageId) return;

  setTimeout(changeInfoEdit, 1000);
});