#!/bin/bash

[ "$APKDEPLOYPATH" == "" ] && (echo APKDEPLOYPATH not set ; exit 1)
[ "$APK" == "" ] && (echo APK not set ; exit 1)

if ! [ -e "$APKDEPLOYPATH" ] ; then
    echo ERROR: APKDEPLOYPATH ${APKDEPLOYPATH} does not exist
    exit 1
fi

# Get tag at current changeset

if ! _tag=`git describe --tags --exact-match HEAD` ; then
    echo ERROR: not on a tag
    exit 1
fi

if ! [ -e "$APK" ] ; then
    echo ERROR: APK ${APK} does not exist
    exit 1
fi

_apkname=`basename $APK`
echo $_apkname
_apk_product=${_apkname%-*-release.apk}

_tag_product=${_tag%%-*}
_tag_remaining=${_tag#${_tag_product}-}
_tag_platform=${_tag_remaining%%-*}
_tag_version_full=${_tag_remaining#${_tag_platform}-}
_tag_version=${_tag_version_full%-rc*}
_tag_rc=${_tag_version_full#${_tag_version}}

if [ "$_tag_product" == "" ] ; then
    echo Error parsing tag: _product is empty
    exit 1
fi
if [ "$_tag_platform" == "" ] ; then
    echo Error parsing tag: _platform is empty
    exit 1
fi
if [ "$_tag_version" == "" ] ; then
    echo Error parsing tag: _version is empty
    exit 1
fi

[ "$DEPLOYNAME" == "" ] && DEPLOYNAME=${_apk_product}
[ "$MARKET" == "" ] || MARKET=-${MARKET}

_final="${APKDEPLOYPATH}/${DEPLOYNAME}-${_tag_version}${MARKET}${_tag_rc}.apk"

echo "============================================================"
echo ""
echo "APK        :  $APK"
echo "              product  : ${_apk_product}"
echo "DEST       :  $APKDEPLOYPATH  (env var APKDEPLOYPATH)"
echo "DEPLOYNAME :  $DEPLOYNAME"
echo "MARKET     :  $MARKET"
echo "TAG        :  \"$_tag\""
echo "              product  :  ${_tag_product}"
echo "              platform :  ${_tag_platform}"
echo "              version  :  ${_tag_version}"
echo "              rc       :  ${_tag_rc}"
echo ""
echo "DEPLOYPATH :  $_final"
echo "============================================================"

if [ -e "$_final" ] ; then
    echo "ERROR: file already exists at destination:"
    echo "  $_final"
    exit 1
fi

echo "Copying $APK"
echo "        -> $_final"
cp "$APK" "$_final"
