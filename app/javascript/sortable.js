import Sortable from 'sortablejs';

document.addEventListener('turbo:load', function(event) {
  const el = document.querySelector('#task-index');
  if (el != null) {
    Sortable.create(el, {
      forceFallback: true,
      fallbackClass: 'sortable-fallback',
      direction: 'vertical',
      delay: 100,
      onUpdate: function (event) {
        const itemElement = event.item;
        const taskId = itemElement.querySelector('.task-id').textContent;
        const newIndex = event.newIndex;

        const newIndexForm = itemElement.querySelector(`#form-new-index-${taskId}`);
        const submitBtn = itemElement.querySelector(`#sort-btn-${taskId}`);

        newIndexForm.value = newIndex;
        submitBtn.click();
      }
    });
  }
});
