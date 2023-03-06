#!/usr/bin/env python3

import pexpect
import sys 
import time
import os

#arg1: source dir
#arg2: dest dir

prt = "Password:"
cmdBase = "scp %s svc.fpgatest@fpga03.cixcomputing.cn:/home/svc.fpgatest/tmp"
mkcmd = "\"mkdir -p %s\"" % sys.argv[2]
print("ssh svc.fpgatest@fpga03.cixcomputing.cn " + mkcmd)
cid = pexpect.spawn("ssh svc.fpgatest@fpga03.cixcomputing.cn " + mkcmd , encoding='utf-8', codec_errors='replace')
cid.logfile = sys.stdout
cid.expect(prt)
# send password
cid.sendline("Cix@88008080")
cid.expect([pexpect.EOF, pexpect.TIMEOUT])

fList = os.popen('ls ' + sys.argv[1]).read().rstrip().split("\n")
print(fList)
for fl in fList:
    print("scp %s svc.fpgatest@fpga03.cixcomputing.cn:%s" % (sys.argv[1]+'/'+fl, sys.argv[2]))
    cid = pexpect.spawn("scp %s svc.fpgatest@fpga03.cixcomputing.cn:%s" %\
         (sys.argv[1] + '/' + fl, sys.argv[2]), encoding='utf-8', codec_errors='replace')
    cid.logfile = sys.stdout
    cid.expect(prt) 
    # send password
    cid.sendline("Cix@88008080")
    mid = cid.expect(['\$', pexpect.EOF, pexpect.TIMEOUT], timeout=600)
    if mid == 2:
        print("File: {0} copy timeout".format(fl))
        sys.exit(1)
