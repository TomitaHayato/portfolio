import { countdownStart }  from './countdown.js' // カウントダウン処理
import { stepClassUpdate } from './step.js'      // stepの表示を変更する処理

document.addEventListener('turbo:load', function(event) {
  stepClassUpdate();
  countdownStart();
});

document.addEventListener('turbo:frame-load', function(event) {
  stepClassUpdate();
  countdownStart();
});