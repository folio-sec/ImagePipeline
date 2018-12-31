#!/bin/sh
set -ex

SCRIPT_DIR=`dirname "$0"`

TDIR=`mktemp -d`
trap "{ cd - ; rm -rf $TDIR; exit 255; }" SIGINT

cd $TDIR

git clone https://github.com/webmproject/libwebp src

CURRENTPATH=`pwd`

(cd src && sh iosbuild.sh)

cd -

mkdir -p "$SCRIPT_DIR/../Vendor/webp/include"
mkdir -p "$SCRIPT_DIR/../Vendor/webp/lib"

cp -a "$TDIR/src/WebPDecoder.framework/Headers/." "$SCRIPT_DIR/../Vendor/webp/include"

xcrun lipo -create "$TDIR/src/WebPDecoder.framework/WebPDecoder" \
                   -o "$SCRIPT_DIR/../Vendor/webp/lib/libwebpdecoder.a"

rm -rf $TDIR
