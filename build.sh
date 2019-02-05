#!/bin/bash

# Copyright (C) 2019 Lau (laststandrighthere@gmail.com)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

KERNEL_DIR=$PWD
CROSS_DIR=~/aarch64-linux-android-4.9
OUT_DIR=$KERNEL_DIR/out
ZIP_DIR=~/AnyKernel2
IMG_DIR=$OUT_DIR/arch/arm64/boot/Image.gz-dtb
DEFCONFIG=$KERNEL_DIR/arch/arm64/configs/rk_defconfig
DEFCONFIG_NAME=rk_defconfig
LOG_DIR=$KERNEL_DIR/logs
NAME=RK_KERNEL

export CROSS_COMPILE=$CROSS_DIR/bin/aarch64-linux-android-
export ARCH=arm64 && export SUBARCH=arm64

#functions
build() {
	rm -rf $LOG_DIR
	mkdir -p $LOG_DIR
	rm -rf $OUT_DIR
	mkdir -p $OUT_DIR
	make O=$OUT_DIR clean
	make O=$OUT_DIR mrproper
	make O=$OUT_DIR $DEFCONFIG_NAME
	echo -e "☆☆☆continue?☆☆☆"
	read choice2
	if [ "$choice2" == "y" ]; then
		make O=$OUT_DIR -j32 #&>$LOG_DIR/logs.txt
		echo -e "~build done"
		if ![ -a $IMG_DIR ]; then
			echo -e "☆☆☆~error during compilation, check logs☆☆☆"
		else
			echo -e "☆☆☆~compilated succesfully☆☆☆"
			rm -rf $LOG_DIR
		fi
	fi
}

regen() {
	make O=$OUT_DIR $DEFCONFIG
	rm $DEFCONFIG
	cp $OUT_DIR/.config $DEFCONFIG
	echo -e "☆☆☆~defconfig regenerated☆☆☆"
}

zip() {
	cd $ZIP_DIR
	make clean
        cp $IMG_DIR $ZIP_DIR/zImage
        make normal
	echo -e "☆☆☆~zipped☆☆☆"
}

upload() {
	cd $ZIP_DIR
	if [ -a $ZIP_DIR/$(NAME)* ]; then
		gdrive upload $(NAME)*.zip
		echo -e "☆☆☆~uploaded☆☆☆"
	else
		echo -e "☆☆☆~no zip to upload☆☆☆"
	fi
}

everything() {
	echo -e "☆☆☆wanna build?☆☆☆"
	read choice
	if [ "$choice" == "y" ]; then
		build
		echo -e "☆☆☆wanna zip?☆☆☆"
		read choice
		if [ "$choice" == "y" ]; then
			zip
			echo -e "☆☆☆wanna upload?☆☆☆"
			read choice
			if ![ "$choice" == "y" ]; then
				upload
			fi
		fi
	fi
	echo -e "☆☆☆done everything☆☆☆"
}

#main
while true; do

	echo -e "☆☆☆starting compilation for vimb kernel☆☆☆"
	echo -e "[1] do everything (will ask for confirmation for each step)"
	echo -e "[2] just build"
	echo -e "[3] regen defconfig"
	echo -e "[4] zip the zImage"
	echo -e "[5] upload the zip to gdrive"
	read choice

	if [ "$choice" == "1" ]; then
		everything
	elif [ "$choice" == "2" ]; then
		build

	elif [ "$choice" == "3" ]; then
		regen

	elif [ "$choice" == "4" ]; then
		zip

	elif [ "$choice" == "5" ]; then
		upload
	fi

done