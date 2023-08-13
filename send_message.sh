#!/bin/bash
ps -eaf | grep send_message.py | grep -v grep
# if not found - equals to 1, start it
if [ $? -eq 1 ]
then
python3 -O /root/variflight/send_message.py &
fi
