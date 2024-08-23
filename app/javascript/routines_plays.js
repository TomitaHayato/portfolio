document.addEventListener("turbo:load", function(event) {
  if (!document.querySelector("#countdown-zone")) return;

  let hourElement = document.querySelector("#hour");
  let minuteElement = document.querySelector("#minute");
  let secondElement = document.querySelector("#second");

  let hour = Number(hourElement.textContent);
  let minute = Number(minuteElement.textContent);
  let second = Number(secondElement.textContent);

  function countdownHour() {
    switch (hour) {
      case 0:
        console.log("カウントダウン終了");
        clearInterval(setIntervalId);
        break;
      default:
        hour = hour - 1;
        if (hour < 10) {
          hourElement.textContent = `0${hour}`;
        } else {
          hourElement.textContent = hour;
        }
        minute = 59;
        minuteElement.textContent = minute;
        second = 59;
        secondElement.textContent = second;
        break;
    }
  }

    function countdownMinute() {
      switch (minute) {
        case 0:
          countdownHour();
          break;
        default:
          minute = minute - 1;
          if (minute < 10) {
            minuteElement.textContent = `0${minute}`;
          } else {
            minuteElement.textContent = minute;
          }
          second = 59;
          secondElement.textContent = second;
          break;
      }
    }

    function countdown() {
      switch (second) {
        case 0:
          countdownMinute();
          break;
        default:
          second = second - 1;
          if (second < 10) {
            secondElement.textContent = `0${second}`;
          } else {
            secondElement.textContent = second;
          }
          break;
      }
    }

    // 1秒ごとにカウントダウンを実行
    const setIntervalId = setInterval(countdown, 1000);

    // ページを離れる前にカウントダウン処理を終了する
    document.addEventListener("turbo:before-visit", function() {
      clearInterval(setIntervalId);
    });
});