#!/bin/bash

set -e

VERSION=$1

if [ -z $VERSION ] ; then
VERSION="1.0.1"
fi

OUT_ZIP="xccleanreport.zip"

printf "Downloading xccleanreport $VERSION\n"


CURL=$(curl -L -s -w "%{http_code}" -o $OUT_ZIP https://github.com/laurenshultz62/XCCleanReport/master/xccleanreport-$VERSION.zip)

if [ ! -f $OUT_PATH ]; then
printf '\e[1;31m%-6s\e[m' "Failed to download XCCleanReport. Make sure the version you're trying to download exists."
printf '\n'
exit 1
fi

unzip $OUT_ZIP

chmod 755 xccleanreport
mv xccleanreport /usr/local/bin/

rm $OUT_ZIP

printf '\e[1;32m%-6s\e[m' "Successully installed XCTestHTMLReport. Execute xccleanreport -h for help."
printf '\n'
exit 0

