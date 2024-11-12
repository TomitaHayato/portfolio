export function stepClassUpdate() {
  const taskPositionEl  = document.querySelector('#task-position-deliver');
  if(!taskPositionEl) return;

  const taskPositionNow = parseInt(taskPositionEl.dataset.taskPosition);
  const stepElNow         = document.querySelector(`#step-${taskPositionNow}`);

  console.log(taskPositionNow);
  stepElNow.classList.add("step-success");

  // 順番が前のタスクのstepにもクラスを追加
  if(taskPositionNow > 1) {
    let stepElBefore = null;

    for (let position = taskPositionNow; position === 1, position--;) {
      stepElBefore = document.querySelector(`#step-${position}`);
      
      if(stepElBefore && !stepElBefore.classList.contains("step-success")) {
        stepElBefore.classList.add("step-success");
      }
    }
  }
}
