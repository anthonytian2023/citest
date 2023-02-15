#!/bin/bash

if [ $1 = 'AP' ]; then
    cd /home/jackeydu/workspace/git/ltp/testcases/cix_tests_suite/fpgaci/ap
elif [ $1 = 'apxip' ]; then
    cd /home/jackeydu/workspace/git/ltp/testcases/cix_tests_suite/brom/ap_xip
else
    cd /home/jackeydu/workspace/git/ltp/testcases/cix_tests_suite/brom/ap_xip_stress
fi
export PATH=/home/jackeydu/.local/bin:$PATH
pytest
rp=`ls -tl reports/*html | head -n 1 | cut -d / -f2`
cp reports/$rp /home/jackeydu/jenkins/workspace/report/reports.html
