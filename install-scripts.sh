#!/bin/sh

REPOS="main ru samples community"
SCRIPTS_DIR="/sdcard/Android/data/ru.execbit.aiolauncher/files/"

adb shell rm -rf $SCRIPTS_DIR/*.lua

for repo in $REPOS; do
    adb push $repo/*.lua $SCRIPTS_DIR
done

