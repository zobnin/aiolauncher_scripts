#!/bin/sh

rm -rf scripts.zip scripts.md5
zip -r scripts.zip -j main/*.lua ru/*.lua
ls -1 main/*.lua ru/*.lua > scripts.index
md5sum scripts.zip | cut -d " " -f 1 > scripts.md5
