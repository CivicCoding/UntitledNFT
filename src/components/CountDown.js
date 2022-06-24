import React from "react";

const CountDown = () => {

    function addZero(time){
        return (time < 10) ? "0" + time : time + "";
    }

    function countDown(){
        //秒
        let today = new Date();
        let endTime = new Date("2022-12");
        let leftTime = Math.round((endTime.getTime() - today.getTime())/1000);

        let days = addZero(Math.round(leftTime/(24*60*60)));
        let hours = addZero(Math.round(leftTime/(60 * 60) % 24));
        let mins = addZero(Math.round((leftTime/60)%60));
        let secounds = addZero(Math.round(leftTime%60));

        let time = document.getElementById("time");
        if(leftTime !== 0){
            time.innerHTML = `还剩下 ${days}天 ${hours} 小时${mins}分${secounds}秒开始活动`;
        }else{
            time.innerHTML = `可以Mint`;
        }
    }

    setInterval(countDown,1000);

    return (
        <div className="CountDown">
            <div id="time"></div>
        </div>
    )
}

export default CountDown;