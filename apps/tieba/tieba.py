#!/usr/bin/env python
# -*- coding: utf-8 -*-
# File: tieba.py
# Author: Zhou
# Date: 2023/9/15
# Copyright: 2023 Zhou
# License:
# Description: 签到


import json
import logging
import os
import re
import requests
import time
from notify import send


class TieBa:
    forums_url = "https://tieba.baidu.com/mo/q/newmoindex"
    signInUri = "https://tieba.baidu.com/sign/add"

    def __init__(self, cookie):
        self.cookie = cookie
        self.tbs = ""
        self.like_forum = []

    def get_forum_list(self):
        payload = {}
        headers = {
            "Content-Type": "application/octet-stream",
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 12_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/16A366",
            "Referer": "https://tieba.baidu.com/index/tbwise/forum",
            "Cookie": self.cookie,
        }
        r = requests.get(self.forums_url, headers=headers, data=payload).json()
        if r.status_code != 200:
            msg = f"获取贴吧列表失败,状态码{r.status_code}"
            send('贴吧', msg)
            print(msg)
            return
        data = r.get("data")
        self.tbs = data.get("tbs")
        self.like_forum = data.get("like_forum")  # [{},{}]

    def signin(self):
        if not all([self.tbs, self.like_forum]):
            print("获取贴吧列表失败,无法签到，程序退出.")
            return
        signed_count = 0
        suc_msg = ""
        err_msg = ""
        headers = {
            "Content-Type": "application/x-www-form-urlencoded",
            "Cookie": self.cookie,
            "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 10_1_1 like Mac OS X; zh-CN) AppleWebKit/537.51.1 (KHTML, like Gecko) Mobile/14B100 UCBrowser/10.7.5.650 Mobile",
        }
        for f in self.like_forum:
            name, level, is_sign, exp = f.get("forum_name"), f.get(
                "user_level"), f.get('is_sign'), f.get('user_exp')
            if is_sign == 1:
                print(f"{name}已签到")
                signed_count += 1
                continue
            body = f"tbs={self.tbs}&kw={name}&ie=utf-8".encode( 'utf-8')
            msg = f"{name}当前等级{level},经验{exp},"
            r = requests.post(self.signInUri, headers=headers, data=body)
            if r.status_code == 200:
                print(f"{name}签到成功")
                msg += '签到成功'
                suc_msg += f"{msg}\n"
                signed_count += 1
            else:
                print(f"{name}签到失败")
                msg += '签到失败'
                err_msg += f"{msg}\n"
            time.sleep(random.randint(1, 5))
        if signed_count == len(self.like_forum):
            t_msg = f"{signed_count}个贴吧全部签到成功！"
        else:
            t_msg = f'{signed_count}个贴吧签到成功,{len(self.like_forum) - signed_count}个失败'
        send('贴吧', f"{suc_msg} {err_msg} {t_msg}")
        print(t_msg)


def main():
    env = os.environ
    cookies = env.get("tieba_cookie")
    if cookies is None:
        logging.error("缺少环境变量tieba_cookies")
        return

    # 初始化对象
    t = TieBa(cookies)
    t.get_forum_list()
    t.singin()


if __name__ == "__main__":
    main()
