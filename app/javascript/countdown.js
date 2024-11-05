function countdownStart() {
  // このページにアクセスした時刻を記録 => 1秒ごとに現在時刻を取得し、アクセス時の時刻との差分(=経過時間)をtaskのtimeから引く
  const countdownDisplay = document.querySelector('#countdown-display');
  if (!countdownDisplay) return;
  
  console.log('カウントダウン開始');
  
  const startTime        = new Date;
  const taskLimitEl      = document.querySelector('#task-estimated-time');
  const taskLimitSec     = parseInt(taskLimitEl.textContent);
  
  // countdownDisplayの小要素を削除 + 秒数 => 'HH:MM:SS'のpタグを生成
  function createTaskLimitStr(second) {
    countdownDisplay.innerHTML = '';

    const taskLimitP       = document.createElement('p');
    taskLimitP.textContent = secondToHHMMSS(second);
    taskLimitP.className   = 'countdown-custom'
    
    countdownDisplay.appendChild(taskLimitP)
  }

  // 秒数 => HH:MM:SSに変換
  function secondToHHMMSS(second) {
    let secondNow = second;
    let hour      = '00';
    let minute    = '00';

    if(secondNow === 0) return '00:00';

    if (secondNow >= 3600) {
      hour       = Math.floor(secondNow / 3600);
      secondNow -= hour * 3600

      hour = digitControl(hour);
    }

    if (secondNow >= 60) {
      minute     = Math.floor(secondNow / 60);
      secondNow -= minute * 60

      minute = digitControl(minute);
    }

    secondNow = digitControl(secondNow);

    return hour + ':' + minute + ':' + secondNow;
  }

  // 文字列に変換 + 2桁に調整
  function digitControl(timeComponent) {
    let timeComponentStr = timeComponent.toString();
    
    if (timeComponentStr.length === 1) { timeComponentStr = '0' + timeComponentStr; }

    return timeComponentStr;
  }

  // 経過時間を計算
  function calPassedSec(startTime) {
    const timeNow    = new Date;
    const passedSec = Math.round(
                                  (timeNow.getTime() - startTime.getTime()) / 1000
                                );
    console.log(passedSec);
    return passedSec;
  }

  // タスクの残り時間を計算
  function calTaskLimitSec(taskLimitSec, startTime) {
    const passedSec = calPassedSec(startTime);

    const taskLimitSecNow = taskLimitSec - passedSec;

    if(taskLimitSecNow < 0) return 0;

    return taskLimitSecNow;
  }

  // 毎秒行う処理
  function countdown() {
    const taskLimitSecNow = calTaskLimitSec(taskLimitSec, startTime);
    createTaskLimitStr(taskLimitSecNow);
    if(taskLimitSecNow === 0) { clearInterval(setIntervalId); }
  }

  // ページ遷移時にカウントダウンを表示
  createTaskLimitStr(taskLimitSec);

  const setIntervalId =  setInterval(countdown, 1000);

  document.addEventListener('turbo:before-visit', function () {
    clearInterval(setIntervalId);
  });
}

document.addEventListener('turbo:load', function(event) {
  countdownStart();
});

document.addEventListener('turbo:frame-load', function(event) {
  countdownStart();
});
