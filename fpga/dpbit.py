#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

"""
1. open and ssh sessions 
2. do  bitfile deploying before test and delete after test
args:
arg1 - the fpga PC name like fpga01 or fpga01-sub1
arg2 - jobdir like $JOB_NAME/$BUILD_NUMBER
arg3 - test model like AP or BROM
arg4 - operation like cp, rm
arg5 - AP bit file version
arg6 - SE bit file version
"""
from pexpect import pxssh
import pexpect
import sys
import os
import time

# global 
pcInfo = {
        "fpga01": {'name': 'svc.fpgatest', 'ip': 'fpga01.cixcomputing.cn', 'passwd': 'Cix@88008080'},
        "fpga02": {'name': 'svc.fpgatest', 'ip': 'fpga02.cixcomputing.cn', 'passwd': 'Cix@88008080'},
        "fpga03": {'name': 'svc.fpgatest', 'ip': 'fpga02.cixcomputing.cn', 'passwd': 'Cix@88008080'},
        }
cPath = os.path.split(os.path.realpath(__file__))[0] + "/"
# fpga CI path
fciPath = "${HOME}/CI/"
apPath = "/home/liming.zhang/fpga_image/ap"
sePath = "/home/jian.guan"
jcmd = "if [ $? -eq 0 ]; then echo 'OPASS'; else echo 'OFAIL'; fi"

# ssh login function
def pSSH(pinfo):
    chdPid = pxssh.pxssh(encoding='utf-8', timeout=5, codec_errors='replace', echo=False)
    # only save output
    chdPid.logfile = sys.stdout
    chdPid.login(pinfo['ip'], pinfo['name'], pinfo['passwd'])
    return chdPid

# ssh basic operations
def bOP(ss, oplist):
    for op, to in oplist:
        ss.sendline(op)
        ss.prompt(timeout=to)
        ss.sendline(jcmd)
        eid = ss.expect([pexpect.EOF, pexpect.TIMEOUT, 'OFAIL', 'OPASS'], timeout=3)
        if eid != 3:
            print("Erorr happens in command %s" % op)
            return 1
        ss.prompt(timeout=3)
        return 0

if __name__ == "__main__":
    # get target PC arg
    tPC = sys.argv[1].split('-')[0]
    pcSSH = pSSH(pcInfo[tPC])
    if sys.argv[3].split('_')[0] == 'AP':
        redPath = apPath + '/' + sys.argv[5]
    else:
        redPath = sePath + '/' + sys.argv[6]

    # set the bitfile PATH
    bPath = fciPath + sys.argv[1] + '/' + sys.argv[2]
    if sys.argv[4] == 'cp':
        cpList = [("mkdir -p " + bPath, 3),
                  ("cp -ar " + redPath + ' ' + bPath, 600),
                    ]
        rv = bOP(pcSSH, cpList)
    if sys.argv[4] == 'rm':
        rmList = [("rm -rf " + bPath, 30),
                 ]
        rv = bOP(pcSSH, rmList)
    sys.exit(rv)
