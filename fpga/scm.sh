#!/bin/bash
mkdir -p $SH_JOBDIR
cd $SH_JOBDIR
git clone --depth 1 ssh://git@gitmirror.cixtech.com/cix_test/ltp
cd -
