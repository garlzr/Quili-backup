const axios = require('axios');
const fs = require('fs');

const backupStatus = process.argv[2];
const statusParts = backupStatus.split("----");
const info = statusParts[1].trim();
const nodeinfo = process.argv[3];
const url2 ="xx"

const data2 = {
  "appToken":"xx",//必传
  //消息摘要，显示在微信聊天页面或者模版消息卡片上，限制长度20(微信只能显示20)，可以不传，不传默认截取content前面的内容。
  "summary":info,
  //内容类型 1表示文字  2表示html(只发送body标签内部的数据即可，不包括body标签，推荐使用这种) 3表示markdown 
  "contentType":2,
  //发送目标的topicId，是一个数组！！！，也就是群发，使用uids单发的时候， 可以不传。
/*  "topicIds":[ 
      123
  ],*/
  //发送目标的UID，是一个数组。注意uids和topicIds可以同时填写，也可以只填写一个。
  "uids":[
      "xx"
  ],
  //是否验证订阅时间，0：不验证，1:只发送给付费的用户，2:只发送给未订阅或者订阅过期的用户
  "verifyPayType":0 
}

console.log(data2)
const messages = nodeinfo;
const content = `<h1>${backupStatus}</h1><br/><p style="color:red;">当前已挖：${messages}</p>`;

const data2WithContent = { ...data2, content};
axios.post(url2, data2WithContent)
      .then(response => {
            console.log('推送成功',response.data);
            })
            .catch(error => {
            console.error('Error sending message:', error);
            });
