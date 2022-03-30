# ！/usr/bin/env python
# encoding:utf-8
# Created by Andy at 2022/3/30

"""酷我音乐app每日签到脚本，当前仅仅做了签到，其它任务暂未做，当前仅仅适用于ios,安卓未测试"""
import requests, json
from functools import partial
from sendNotify import send

# import sendNotify
header = {
    "Accept": "*/*",
    "Accept-Encoding": "gzip, deflate",
    "Accept-Language": "zh-cn",
    "Connection": "close",
    "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8", "Host": "wapi.kuwo.cn",
    "Origin": "http://m.kuwo.cn", "Referer": "http://m.kuwo.cn/newh5/score/index?transparentTitleView=1&src=1",
    "User-Agent":
        "Mozilla/5.0 (iPhone; CPU iPhone OS 13_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 TencentMTA/1 kuwopage"}

param = ''
sign_url = f'http://wapi.kuwo.cn/api/kudou/sign?{param}'

get = partial(requests.get, headers=header)
post = partial(requests.post, headers=header)


def sign_in():
    """
    Func:签到
    Args:
    Example:
    Return: None
    Author: Andy
    Version: 1.0
    Created: 2022/3/30 下午9:06
    Modified: 2022/3/30 下午9:06
    """
    result = post(
        url=sign_url,
        headers=header,
    )
    if result.status_code == 200:
        result = json.loads(result.text)
        data = result.get('data')
        if data.get('isSign'):
            msg = f"签到成功，增加{data.get('addScore')}分，总签到天数{data.get('days')},"\
             "连续签到{data.get('continueDays')}天,当前总积分{data.get('remainScore')}"
        else:
            msg = f"""未知错误，code={data.get('code')},msg={data.get('msg')}"""
    else:
        msg = f"请求出错，返回状态码为{result.status_code}"
    return msg


if __name__ == '__main__':
    msg = sign_in()
    send('酷我音乐', msg)
