#!/bin/bash
tdir=$HOME/CI/$1
mkdir -p $tdir
cd $tdir
git clone --depth 1 ssh://git@gitmirror.cixtech.com/cix_test/ltp
cd -
