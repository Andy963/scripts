const axios = $.isNode() ? require('axios') : "";
const notify = $.isNode() ? require('./sendNotify') : "";

class TieBa {
    constructor(cookie) {
        this.forums_url = "https://tieba.baidu.com/mo/q/newmoindex";
        this.signInUri = "https://tieba.baidu.com/sign/add";
        this.cookie = cookie;
        this.tbs = "";
        this.like_forum = [];
    }

    async get_forum_list() {
        const headers = {
            "Content-Type": "application/octet-stream",
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16A366",
            "Referer": "https://tieba.baidu.com/index/tbwise/forum",
            "Cookie": this.cookie,
        };
        try {
            const response = await axios.get(this.forums_url, {headers});
            if (response.status !== 200) {
                const msg = `获取贴吧列表失败,状态码${response.status}`;
                notify.sendNotify('贴吧', msg);
                console.log(msg);
                return;
            }
            const data = response.data.data;
            this.tbs = data.tbs;
            this.like_forum = data.like_forum;
        } catch (error) {
            console.error(error);
        }
    }

    async signin() {
        if (!this.tbs || !this.like_forum) {
            let msg = "获取贴吧列表失败,无法签到，程序退出.";
            console.log(msg)
            notify.sendNotify('贴吧', msg)
            return;
        }
        let signed_count = 0;
        let suc_msg = "";
        let err_msg = "";
        const headers = {
            "Content-Type": "application/x-www-form-urlencoded",
            "Cookie": this.cookie,
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 10_1_1 like Mac OS X; zh-CN) AppleWebKit/537.51.1 (KHTML, like Gecko) Mobile/14B100 UCBrowser/10.7.5.650 Mobile",
        };
        for (let f of this.like_forum) {
            const name = f.forum_name;
            const level = f.user_level;
            const is_sign = f.is_sign;
            const exp = f.user_exp;
            if (is_sign === 1) {
                console.log(`${name}已签到`);
                signed_count += 1;
                continue;
            }
            const body = `tbs=${this.tbs}&kw=${name}&ie=utf-8`;
            let msg = `${name}当前等级${level},经验${exp},`;
            try {
                const response = await axios.post(this.signInUri, body, {headers});
                if (response.status === 200) {
                    console.log(`${name}签到成功`);
                    msg += '签到成功';
                    suc_msg += `${msg}\n`;
                    signed_count += 1;
                } else {
                    console.log(`${name}签到失败`);
                    msg += '签到失败';
                    err_msg += `${msg}\n`;
                }
            } catch (error) {
                console.error(error);
            }
        }
        let t_msg;
        if (signed_count === this.like_forum.length) {
            t_msg = `${signed_count}个贴吧全部签到成功！`;
        } else {
            t_msg = `${signed_count}个贴吧签到成功,${this.like_forum.length - signed_count}个失败`;
        }
        notify.sendNotify('贴吧', suc_msg + err_msg + t_msg);
        console.log(t_msg);
    }

}

async function main() {
    const cookies = process.env.tieba_cookie;
    if (!cookies) {
        console.error("缺少环境变量tieba_cookies");
        return;
    }

    // 初始化对象
    const t = new TieBa(cookies);
    await t.get_forum_list();
    await t.signin();
}

main();
