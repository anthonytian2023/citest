#!/usr/bin/env python3
# -*- encoding: utf-8 -*-

"""
1. update pytest.in
2. update data/conf.yml
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
import sys
import os
import time
import yaml
import configparser

cPath = os.path.split(os.path.realpath(__file__))[0] + "/"
# Jenkins CI path
jciPath = os.environ['HOME'] + "/CI/" + sys.argv[2] + '/'
ltpPath = "ltp/testcases/cix_tests_suite/fpgaci/pengine"
iniF = jciPath + ltpPath + '/pytest.ini'
ymlF = jciPath + ltpPath + '/data/conf.yml'
if sys.argv[3].split('_')[0] == 'AP':
    bVer = sys.argv[4]
else:
    bVer = sys.argv[5]
bitPath = "/home/svc.fpgatest/CI/{0}/{1}/{2}".format(sys.argv[1], sys.argv[2], bVer)
fDict = {'fpga01': 'fpga1 fpga-1',
         'fpga02': 'fpga2 fpga-2',
         'fpga03-sub1': 'fpga3-sub1 fpga-3',
         'fpga03-sub2': 'fpga3-sub2 fpga-3',
         'fpga03-sub3': 'fpga3-sub3 fpga-3',
        }
#plat = fDict[sys.argv[1]].split()[0].split('_')[0]
plat = fDict[sys.argv[1]].split()[0].split('_')[0]
platXM = fDict[sys.argv[1]].split()[1]

iList = [('env', '\nPLAT={0}'.format(plat)),
        ]
yList = [('rpath', bitPath),
         ('name', platXM),
         ('qpath', bitPath),
        ]

def ymlUpdate(yfile, plt, ylist):
    """
    Update yml file
    """
    with open(yfile, encoding='utf-8') as f:
        cInfo = yaml.safe_load(f)
    for key, value in ylist:
        cInfo[plt][key] = value
    with open(yfile, 'w', encoding='utf-8') as f:
        yaml.safe_dump(cInfo, f, default_flow_style=False)

def iniUpdate(yfile, ylist):
    """
    Update yml file
    """
    conf = configparser.ConfigParser()
    conf.read(yfile, encoding='utf-8')
    for key, value in ylist:
        conf.set('pytest', key, value)
    conf.write(open(yfile, 'w'))

if __name__ == "__main__":
    iniUpdate(iniF, iList)
    ymlUpdate(ymlF, plat, yList)
