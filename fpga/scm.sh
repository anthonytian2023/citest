#!/bin/bash
tdir=$HOME/CI/$1
if [ $2 == setup ]; then
    mkdir -p $tdir
    cd $tdir
    git clone --depth 1 ssh://git@gitmirror.cixtech.com/cix_test/ltp -b cix_master
    cd -
else
    rm -rf $tdir
fi
