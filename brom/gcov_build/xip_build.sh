#!/bin/bash -x

sPath=$1
oPath=$2
bxip="component/cix_firmware/fpga/brom/brom_xip.bin"
tList="output/cix_fpga/SKY1_BL33_UEFI.fd output/cix_fpga/pbl_fw.bin \
	   output/cix_fpga/bootloader1.img output/cix_fpga/tf-a.bin output/cix_fpga/tee.bin"

mkdir -p ${oPath}/ap/rsa
mkdir -p ${oPath}/ap/sm2
cd $sPath

# basic building behavior
bb(){
    rv=0
    source build-scripts/envtool.sh
    echo "NO" | config -p cix -f debian -k rsa3072 -b fpga
    # enable gcov
    sed -i -e 's/CONFIG_GCOV_ENABLE := n/CONFIG_GCOV_ENABLE := y/g' security/bootrom/config/config_secure_boot.mk
    # enable AP uart
    if [ "$1" = "AP" ]; then
        sed -i 's/CONFIG_SUB_CSU := y/CONFIG_SUB_CSU := n/g' security/bootrom/config/config_secure_boot.mk
    else
        sed -i 's/CONFIG_SUB_CSU := n/CONFIG_SUB_CSU := y/g' security/bootrom/config/config_secure_boot.mk
    fi
    # do test configure
	if [ "$2" = "no" ]; then
		sed -i 's/CONFIG_TEST_ENABLE := y/CONFIG_TEST_ENABLE := n/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_SMOKE_ENABLE := y/CONFIG_TEST_SMOKE_ENABLE := n/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_SANITY_ENABLE := y/CONFIG_TEST_SANITY_ENABLE := n/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_FUNC_ENABLE := y/CONFIG_TEST_FUNC_ENABLE := n/g' security/bootrom/config/config_secure_boot.mk
	elif [ "$2" = "smoke" ]; then
		sed -i 's/CONFIG_TEST_ENABLE := n/CONFIG_TEST_ENABLE := y/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_SMOKE_ENABLE := n/CONFIG_TEST_SMOKE_ENABLE := y/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_SANITY_ENABLE := y/CONFIG_TEST_SANITY_ENABLE := n/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_FUNC_ENABLE := y/CONFIG_TEST_FUNC_ENABLE := n/g' security/bootrom/config/config_secure_boot.mk
	elif [ "$2" = "sanity" ]; then
		sed -i 's/CONFIG_TEST_ENABLE := n/CONFIG_TEST_ENABLE := y/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_SMOKE_ENABLE := y/CONFIG_TEST_SMOKE_ENABLE := n/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_SANITY_ENABLE := n/CONFIG_TEST_SANITY_ENABLE := y/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_FUNC_ENABLE := y/CONFIG_TEST_FUNC_ENABLE := n/g' security/bootrom/config/config_secure_boot.mk
	elif [ "$2" = "func" ]; then
		sed -i 's/CONFIG_TEST_ENABLE := n/CONFIG_TEST_ENABLE := y/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_SMOKE_ENABLE := y/CONFIG_TEST_SMOKE_ENABLE := n/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_SANITY_ENABLE := y/CONFIG_TEST_SANITY_ENABLE := n/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_FUNC_ENABLE := n/CONFIG_TEST_FUNC_ENABLE := y/g' security/bootrom/config/config_secure_boot.mk
	else
		sed -i 's/CONFIG_TEST_ENABLE := n/CONFIG_TEST_ENABLE := y/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_SMOKE_ENABLE := n/CONFIG_TEST_SMOKE_ENABLE := y/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_SANITY_ENABLE := n/CONFIG_TEST_SANITY_ENABLE := y/g' security/bootrom/config/config_secure_boot.mk
		sed -i 's/CONFIG_TEST_FUNC_ENABLE := n/CONFIG_TEST_FUNC_ENABLE := y/g' security/bootrom/config/config_secure_boot.mk
	fi

    echo "NO" | build bootrom > b_${1}_rsa_{2}_test.log 2>&1
	if [ $? -ne 0 ]; then
		echo "Build FAIL for configure - $1: $2"
    	let rv=rv+$?
		return $rv
    fi
    cp security/bootrom/brom.bin ${bxip}
    tar cf ${oPath}/ap/rsa/gcov_${1}_${2}_test.tar.gz security/bootrom/tool/gcov
    clean bootrom > c_${1}_${2}_rsa_no_test.log 2>&1
	if [ $? -ne 0 ]; then
		echo "Clean FAIL for configure - $1: $2"
    	let rv=rv+$?
		return $rv
    fi
    # build SE FW and no need to deploy SE FW
    build firmware > b_fw_rsa_${2}_test.log 2>&1
	if [ $? -ne 0 ]; then
		echo "Build SE FW FAIL for configure - $1: $2"
    	let rv=rv+$?
		return $rv
    fi
    # build mkimage
    touch ${tList}
    ls -ltrh ${tList}
    build mkimage > b_mk_${1}_rsa_${2}_test.log 2>&1
	if [ $? -ne 0 ]; then
		echo "Build mkimage FAIL for configure - $1: $2"
    	let rv=rv+$?
		return $rv
    fi
    cp output/cix_fpga/cix_flash_all.bin ${oPath}/ap/rsa/cix_flash_all_${1}_${2}_test.bin
    clean firmware > c_fw_rsa_${2}_test.log 2>&1
	if [ $? -ne 0 ]; then
		echo "Clean SE FW FAIL for configure - $1: $2"
    	let rv=rv+$?
		return $rv
    fi
}

# bitfile list
bList="AP SE"
# test mode
tmList="no smoke sanity func all"
RV=0

for bi in $bList; do
	for tm in $tmList; do
		bb $bi $tm
		let RV=RV+$?
    done
done
if [ $RV -ne 0 ]; then
	echo "Building Fail"
	exit $RV
fi

