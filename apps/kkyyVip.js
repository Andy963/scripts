/*
 * @Author: Andy963 Andy963@users.noreply.github.com
 * @Date: 2024-02-04 14:32:16
 * @LastEditors: Andy963 Andy963@users.noreply.github.com
 * @LastEditTime: 2024-02-05 14:03:05
 * @FilePath: \undefinedd:\PycharmProjects\own\scripts\apps\kkyyVip.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */

function getExpireStr() {
    let d = new Date();
    return d.setDate(d.getDate() + 30) / 1000;
}

let body = $response.body;
let obj = JSON.parse(body);
if (obj?.Data?.is_vip === 0) {
    obj['Data']['is_changxue'] = 1;
    obj['Data']['expire_time'] = getExpireStr();
    obj['Data']['changxue_end_time'] = getExpireStr();
}
body = JSON.stringify(obj);

console.log(body);

$done(body);