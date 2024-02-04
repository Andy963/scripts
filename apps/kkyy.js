// env.js 全局
const $ = new Env("可可英语签到");
const ckName = "kk_tk";
//-------------------- 一般不动变量区域 -------------------------------------
const Notify = 1;//0为关闭通知,1为打开通知,默认为1
const notify = $.isNode() ? require('./sendNotify') : '';
let envSplitor = ["@"]; //多账号分隔符
let userCookie = ($.isNode() ? process.env[ckName] : $.getdata(ckName)) || '';
let userList = [];
let userIdx = 0;
let userCount = 0;


//获取Token
async function getCookie() {
    if ($request && $request.method != 'OPTIONS') {
        const tokenValue = $request.body['Token'];
        const uid = $request.body['UID'];
        const sign = $request.body['Sign'];
        if (tokenValue && uid) {
            $.setdata({"UID": uid, "Token": tokenValue, "Sign": sign}, ckName);
            console.log(tokenValue);
            $.msg($.name, "", "获取签到Token成功🎉");
        } else {
            $.msg($.name, "", "错误获取签到Token失败");
        }
    }
}

//检查变量
async function checkEnv() {
    if (userCookie) {
        // console.log(userCookie);
        let e = envSplitor[0];
        for (let o of envSplitor)
            if (userCookie.indexOf(o) > -1) {
                e = o;
                break;
            }
        for (let n of userCookie.split(e)) n && userList.push(new UserInfo(n));
        userCount = userList.length;
    } else {
        console.log("未找到token");
        return;
    }
    return console.log(`共找到${userCount}个账号`), true;//true == !0
}

class UserInfo {
    constructor(uid, token, sign) {
        this.index = ++userIdx;
        this.uid = uid;
        this.sign = sign || "c00dda77d2c16df052516fdc603005a6";
        this.token = token; // 用户token
        this.apVersion = apVersion || "4.9.6";
        this.version = version || "4.0";
        this.versionCode = versionCode || "496";
        this.signinStatus = false; // 是否签到过
        this.ckStatus = true;
    }

    //查询签到情况
    async cx() {
        try {
            const options = {
                url: `https://mob2015.kekenet.com/keke/mobile/index.php`,
                headers: {
                    'Accept': `*/*`,
                    'Accept-Encoding': `gzip, deflate, br`,
                    'Connection': `keep-alive`,
                    'Content-Type': `application/json`,
                    'Host': `mob2015.kekenet.com`,
                    'User-Agent': `KeKeEnglish/4.9.6 (iPhone; iOS 16.5; Scale/2.00)`,
                    'Accept-Language': `en-CN;q=1, zh-Hans-CN;q=0.9`
                },
                body: JSON.stringify({
                    "UID": `${this.uid}`,
                    "Token": `${this.Token}`,
                    "Terminal": "1",
                    "ApVersion": `${this.apVersion}`,
                    "Method": "customer_getmoresetting",
                    "Version": `${this.version}`,
                    "AppFlag": 0,
                    "Sign": `${this.sign}`,
                    "ApTime": `${getTimeStr()}`,
                    "ApVersionCode": `${this.versionCode}`,
                })
            };
            //post方法
            let result = await httpRequest(options);
            //console.log(result)
            if (result?.Code === 200) {
                let data = result ? Data;
                let levelInfo = data?.levelinfo;
                let total = levelInfo?.total
                let level = levelInfo?.level
                let title = levelInfo.title
                let signNum = data?.signnum;
                let username = data?.username;
                let todaySign = data?.todaysign === 1 ? true : false;
                if (todaySign) {
                    this.signStatus = true;
                }
                $.log(`✅查询成功:\n ${username} 等级：${level}, ${title},本月签到次数：${signNum}次，总可豆： ${total}, ${todaySign ? "已签到" : "未签到"}`);
            } else {
                $.log(`❌查询失败!${result?.msg}`)
            }
        } catch (e) {
            console.log(e);
        }
    }


    async signin() {
        if (this.signinStatus) {
            $.signMsg = "已经签到过了"
            $.log(`✅账号${this.index} >> 今天已签到过!`);
            return
        }
        try {
            const options = {
                //签到任务调用签到接口
                url: `https://mob2015.kekenet.com/keke/mobile/index.php`,
                //请求头, 所有接口通用
                headers: {
                    'Accept': `*/*`,
                    'Accept-Encoding': `gzip, deflate, br`,
                    'Connection': `keep-alive`,
                    'Content-Type': `application/json`,
                    'Host': `mob2015.kekenet.com`,
                    'User-Agent': `KeKeEnglish/4.9.6 (iPhone; iOS 16.5; Scale/2.00)`,
                    'Accept-Language': `en-CN;q=1, zh-Hans-CN;q=0.9`
                },
                body: {
                    "UID": `${this.uid}`,
                    "Params": {},
                    "Token": `${this.token}`,
                    "Terminal": "1",
                    "ApVersion": `${this.apVersion}`,
                    "Method": "customer_sign",
                    "Version": `${this.version}`,
                    "AppFlag": 0,
                    "Sign": `${this.sign}`,
                    "ApTime": `${getTimeStr()}`,
                    "ApVersionCode": `${this.apVersionCode}`,
                }
            };
            //post方法
            let result = await httpRequest(options);
            console.log(result)
            if (result?.Code === 200) {
                $.log(`✅签到成功！获得${result?.Data?.point}积分！`);
                $.signMsg = `${result?.msg}`;
                this.signinStatus = true;
            } else {
                $.log(`❌签到失败!${result?.msg}`);
            }
        } catch (e) {
            console.log(e);
        }
    }
}

//脚本入口函数main()
async function main() {
    console.log('\n================== 可可英语签到任务 ==================\n');
    let taskall = [];
    for (let user of userList) {
        if (user.ckStatus) {
            //ck未过期，开始执行任务
            // DoubleLog(`🔷账号${user.index} >> Start work`)
            console.log(`随机延迟${user.getRandomTime()}ms`);
            await user.cx();
            await user.signin();
            DoubleLog(`签到:${$.signMsg}-本次获得：${user.curAward}积分:共：${user.totalAward}积分！\n`);
        } else {
            //将ck过期消息存入消息数组
            $.notifyMsg.push(`❌账号${user.index} >> Check ck error!`)
        }
    }
}

//主程序执行入口
!(async () => {
    //没有设置变量,执行Cookie获取
    if (
        typeof $request != "undefined") {
        await getCookie();
        return;
    }

//未检测到ck，退出
    if (!(await checkEnv())) {
        throw new Error(`❌未检测到token，请添加环境变量`)
    }
    if (userList.length > 0) {
        await main();
    }
})()
    .catch((e) => $.notifyMsg.push(e.message || e))//捕获登录函数等抛出的异常, 并把原因添加到全局变量(通知)
    .finally(async () => {
        await SendMsg($.notifyMsg.join('\n'))//带上总结推送通知
        $.done(); //调用Surge、QX内部特有的函数, 用于退出脚本执行
    });

/** --------------------------------辅助函数区域------------------------------------------- */
function padZero(n) {
    // 小于10时自动补0
    return n < 10 ? '0' + n : n;
}

function getTimeStr() {
    // 获取时间戳
    let d = new Date();
    return d.getTime();
}

function getCurDate() {
    // 获取当前日期格式化字符串
    let d = new Date();
    const year = d.getFullYear();
    const month = padZero(d.getMonth() + 1);
    const date = padZero(d.getDate());

    return `${year}-${month}-${date}` // 2023-02-15
}
