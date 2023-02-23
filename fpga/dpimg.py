#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

"""
1. open and ssh sessions 
2. do  bitfile deploying before test and delete after test
args:
arg1 - the fpga PC name like fpga01 or fpga01-sub1
arg2 - jobdir like $JOB_NAME/$BUILD_NUMBER
arg3 - test model like AP or BROM
arg4 - AP Bit Version
arg5 - SE Bit Version
arg6 - Image Type like CI/Daily/Release
arg7 - Image version like 2023022219-0000201
argx - others due to the operation
"""
from pexpect import pxssh
import pexpect
import sys
import os
import time

cPath = os.path.split(os.path.realpath(__file__))[0] + "/"
# fpga CI path
fciPath = "${HOME}/CI/"
rfciPath = "/home/svc.fpgatest/CI/"
lImgRP = fciPath + 'nexus' # nexus image store root path in local
ltImgP = sys.argv[2] # nexus image store target path in local
lrImgP = sys.argv[6].split('/')[1] + '/cix-fpga/'  + sys.argv[7] # path to release images
fnImgP = lImgRP + '/' + ltImgP + '/' + lrImgP + '/' # local image full path
nLink = "https://artifacts.cixtech.com/#browse/browse:{0}:{1}%2Fcix-fpga%2F{2}".format(\
        sys.argv[6].split('/')[0], sys.argv[6].split('/')[1], sys.argv[7])

def ndl(rnlist=None):
    """
    Nexus image download to local
    """
    nHome = os.popen('echo ' + lImgRP).read().strip()
    print("nexus home: " + nHome)
    os.chdir(nHome)
    rv = os.system("repo artifact-dl " +  nLink + ' ' + ltImgP)
    if rv != 0:
        print("Error when try to download nexus image: \
                {0}".format(nLink))
        sys.exit(rv)
    # rename if needed
    for old, new in rnlist:
        os.system('mv ' + fnImgP + old + ' ' + fnImgP + new)

if __name__ == "__main__":
    # fetch image to local
    rnL = [('brom.hex', 'boot_rom.hex'),]
    ndl(rnL)
    # scp image to remote FPGA PC
    bPath = rfciPath + sys.argv[1] + '/' + sys.argv[2]
    os.system('{2}scp.py {0} {1}'.format(fnImgP, bPath, cPath))
