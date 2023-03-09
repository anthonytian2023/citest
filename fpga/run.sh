#!/bin/bash
tdir=$HOME/CI/$1
cd $tdir
export PATH=/home/jackeydu/.local/bin:$PATH
cd ltp/testcases/cix_tests_suite/fpgaci/pengine
ttl=$2
tter="SW-Test-Robot"
dsc="$2_Auto_Test"
rFlag="--report=report.html --title=$ttl --tester=$tter --desc=$dsc"
if [ -n "$7" ]; then
    kFlag="-m $7"
else
    kFlag="-m bspci"
fi
pytest $rFlag $kFlag
rp=`ls -tl reports/*html | head -n 1 | cut -d / -f2`
# need to modify it to related with jobid
cp reports/$rp /home/jackeydu/jenkins/workspace/report/reports.html
cp result.txt /home/jackeydu/jenkins/workspace/report/
