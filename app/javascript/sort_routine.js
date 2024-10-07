document.addEventListener("turbo:load", function(event) {
  const searchBtn = document.getElementById('search-btn');
  const sortSelectBoxes = document.querySelectorAll('.sort-select-box');

  if (!searchBtn) return;
  for (let sortSelectBox of sortSelectBoxes) {
    sortSelectBox.addEventListener('change', function() {
      searchBtn.click();
      console.log('変更されました');
    });
  }
});