#!/bin/bash
# Copyright (C) 2019 The Raphielscape Company LLC.
#
# Licensed under the Raphielscape Public License, Version 1.b (the "License");
# you may not use this file except in compliance with the License.
#
# CI Runner Script for Generation of blobs

# We need this directive
# shellcheck disable=1090

tg_sendinfo() { 
        curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="<b>Daily build static toolchain</b> CI Triggered%0ADrone triggered by: <code>${DRONE_BUILD_EVENT}</code> event%0AJob name: <code>BakingCC</code>%0A<b>Pipeline jobs</b> <a href='https://cloud.drone.io/Reinazhard/gcc-builder/${DRONE_BUILD_NUMBER}'>here</a>%0A"
}

tg_postinfo() { 
        curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_TOKEN/sendMessage" \
        -d chat_id="$CHAT_ID" \
        -d "disable_web_page_preview=true" \
        -d "parse_mode=html" \
        -d text="Job <code>BakingCC</code> completed and pushed to%0A\<a href='https://github.com/Reinazhard/gcc.git'>Repo</a>%0A%0A@eve_enryu Check it plx!"
}

build_env() {
        export CHAT_ID="-1001403511595"
        tg_sendinfo
        git clone https://github.com/crosstool-ng/crosstool-ng
        cd crosstool-ng
        ./bootstrap
        ./configure
        make -j$(nproc --all)
        make install
        cd ..
        rm -rf crosstool-ng
        HOME_DIRR=$PWD
        export HOME_DIRR
        echo "Build Dependencies Installed....."
}

build_conf() {
        mkdir repo
        cd repo
        git config --global user.email "muh.alfarzoy@gmail.com"
        git config --global user.name "Reinazhard"
}

run() {
        echo "Starting build!"
        git clone https://github.com/najahiiii/Noob-Script.git -b noob config 
        cd config
        mv tc-configs/defconfig_aarch64-elf defconfig 
        ct-ng defconfig
        ct-ng show-tuple
        ct-ng build 
        echo "Build finished!"
}

push_gcc() {
        chmod -R 777 "$HOME"/x-tools
        cd "$HOME"/x-tools/
        git clone https://$GH_TOKEN@github.com/silont-project/aarch64-elf-gcc.git push
        cd push
        rm -r *
        mv ../aarch64-elf/* .
        git add .
        git commit -m "[DroneCI]: GCC-11 $(date +%d%m%y)" --signoff
        git push -q https://$GH_TOKEN@github.com/silont-project/aarch64-elf-gcc.git 11.x 
        tg_postinfo
        echo "Job Successful!"
}

build_env
build_conf
run
push_gcc
