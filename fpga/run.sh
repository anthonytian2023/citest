#!/bin/bash
tdir=$HOME/CI/$1
cd $tdir
export PATH=/home/jackeydu/.local/bin:$PATH
cd ltp/testcases/cix_tests_suite/fpgaci/pengine
pytest
rp=`ls -tl reports/*html | head -n 1 | cut -d / -f2`
# need to modify it to related with jobid
cp reports/$rp /home/jackeydu/jenkins/workspace/report/reports.html
