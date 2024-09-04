import Sortable from 'sortablejs';

document.addEventListener("turbo:load", function(event) {
  const el = document.querySelector('#task-index');
  if (el != null) {
    Sortable.create(el, {
      forceFallback: true,
      fallbackClass: "sortable-fallback",
      direction: 'vertical'
    });
  }
});
