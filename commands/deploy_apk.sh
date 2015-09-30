#!/bin/bash

[ "$APKDEPLOYPATH" == "" ] && (echo APKDEPLOYPATH not set ; exit 1)
[ "$APK" == "" ] && (echo APK not set ; exit 1)

if ! [ -e "$APKDEPLOYPATH" ] ; then
    echo ERROR: APKDEPLOYPATH ${APKDEPLOYPATH} does not exist
    exit 1
fi

if ! [ -e "$APK" ] ; then
    echo ERROR: APK ${APK} does not exist
    exit 1
fi

_apkname=`basename $APK`
echo $_apkname
_apk_product=${_apkname%-*-release.apk}
_apk_remaining=${_apkname#${_apk_product}-}
_apk_version=${_apk_remaining%-release.apk}

echo _apkname = ${_apkname}
echo _apk_product = ${_apk_product}
echo _apk_remaining = ${_apk_remaining}
echo _apk_version = ${_apk_version}

[ "$MARKET" == "" ] || MARKET=-${MARKET}

# Get tag at current changeset

if ! _tag=`git describe --tags --exact-match HEAD` ; then

    _ut=`git log -n 1 --format=%ct`
    _timestamp=`python -c "import datetime; print datetime.datetime.utcfromtimestamp(int("$_ut")).strftime('%Y-%m-%d-%H%M%S')"`
    if [ "" == "${_timestamp}" ] ; then
        echo ERROR: failed to parse commit timestamp
        exit 1
    fi

    _commit=`git log -n 1 --format=%h`
    if [ "" == "${_commit}" ] ; then
        echo ERROR: failed to extract commit hash
        exit 1
    fi

    _final="${APKDEPLOYPATH}/${_apk_product}-${_apk_version}${MARKET}--${_timestamp}--${_commit}.apk"


    echo "============================================================"
    echo ""
    echo "APK        :  $APK"
    echo "              product  : ${_apk_product}"
    echo "              version  : ${_apk_version}"
    echo "DEST       :  $APKDEPLOYPATH  (env var APKDEPLOYPATH)"
    echo "MARKET     :  $MARKET"
    echo "COMMIT     :  \"$_commit\""
    echo "              timestamp  :  ${_timestamp}"
    echo ""
    echo "DEPLOYPATH :  $_final"
    echo "============================================================"

else

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

    _final="${APKDEPLOYPATH}/${DEPLOYNAME}-${_tag_version}${MARKET}${_tag_rc}.apk"

    echo "============================================================"
    echo ""
    echo "APK        :  $APK"
    echo "              product  : ${_apk_product}"
    echo "              version  : ${_apk_version}"
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

fi

if [ -e "$_final" ] ; then
    echo "ERROR: file already exists at destination:"
    echo "  $_final"
    exit 1
fi

echo "Copying $APK"
echo "        -> $_final"
cp "$APK" "$_final"
