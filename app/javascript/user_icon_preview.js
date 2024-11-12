document.addEventListener('turbo:load', function(event) {
  const fileField = document.querySelector('#user_avatar');
  const imgZone   = document.querySelector('#img-zone');

  if (!fileField || !imgZone) return;

  fileField.addEventListener('change', function(e) {
    const file      = fileField.files[0];

    if (file) {
      // 古い画像を削除
      const oldImg = document.querySelector('#preview');
      oldImg.remove();

      // 新しい画像のimg要素を生成する
      const newImg = document.createElement('img');
      newImg.id = 'preview';
      newImg.className = 'rounded-circle mb-3 mx-auto size-[150px]';
      newImg.src = URL.createObjectURL(file);

      // 生成した要素をimgZoneの子要素としてHTMLに追加する
      imgZone.appendChild(newImg);
    }
  });
});
