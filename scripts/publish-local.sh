#! /bin/bash

LOCAL="/Users/koller/Library/ApplicationSupport/typst/packages/local"
echo "$LOCAL"
mkdir -p "$LOCAL"

cp -r release/preview/pergamon "$LOCAL"
