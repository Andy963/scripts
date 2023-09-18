#!/usr/bin/env python
# -*- coding: utf-8 -*-
# File: rem.py
# Author: Zhou
# Date: 2023/9/15
# Copyright: 2023 Zhou
# License:
# Description: remember something

import time
from datetime import datetime
from notify import send
t = time.gmtime()
y = t.tm_year
y_days = t.tm_yday

meet = ""
love = ""

meet_time = datetime.strptime(meet, "%Y-%m-%d")
love_time = datetime.strptime(love, "%Y-%m-%d")

now = datetime.now()

meet_dif  = now -meet_time
love_dif = now - love_time

msg = f"今天是{y}年的第{y_days}天\n距离我们的已经过去了{meet_dif.days}天\n距离我们的已经过去了{love_dif.days}天\n"

if __name__ == "__main__":
    send('记忆', msg)