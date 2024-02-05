/*
 * @Author: Andy963 Andy963@users.noreply.github.com
 * @Date: 2024-02-04 14:32:16
 * @LastEditors: Andy963 Andy963@users.noreply.github.com
 * @LastEditTime: 2024-02-05 14:03:05
 * @FilePath: \undefinedd:\PycharmProjects\own\scripts\apps\kkyyVip.js
 * @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
 */
const is_vip = 'var is_vip=0';
const is_vip_str = 'var is_vip=1'
const end_time = `var end_time=0`;
const end_time_str = `var end_time=${getExpireStr()}`;
const expire_time = 'var expire_time=0';
const expire_time_str = `var expire_time=${getExpireStr()}`;
const body = $response.body.replace(is_vip, is_vip_str).replace(expire_time, expire_time_str).replace(end_time, end_time_str);
$done({body: body})

//主程序执行入口

function getExpireStr() {
    let d = new Date();
    return d.setMonth(d.getMonth() + 6 + 1);
}
