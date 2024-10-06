document.addEventListener('turbo:load', function(event) {
  const resetBtns = document.querySelectorAll('.reset-button');
  const formInputs = document.querySelectorAll('.form-input');

  if (resetBtns.length === 0) return;

  for (let i = 0; i < resetBtns.length; i++ ) {
    let resetBtn = resetBtns[i]
    let formInput = formInputs[i]

    resetBtn.addEventListener('click', function() {
      formInput.value = ""
    });
  }
});
