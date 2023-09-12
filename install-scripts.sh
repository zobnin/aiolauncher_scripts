#!/bin/sh

source ./env

./rm-scripts.sh

for repo in $REPOS; do
    adb push $repo/*.lua $SCRIPTS_DIR
done

