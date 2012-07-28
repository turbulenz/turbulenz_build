#!/usr/bin/python

# Copyright (c) 2012 Turbulenz Limited.
# Released under "Modified BSD License".  See COPYING for full text.

import sys
import copy

BUNDLE_NAME = 'Turbulenz Engine'
BUNDLE_EXECUTABLE = 'TurbulenzEngine'
BUNDLE_ID = 'com.turbulenz.engine'
BUNDLE_FULLVERSION = None
BUNDLE_VERSION = None
BUNDLE_SHORTVERSION = None
BUNDLE_DESCRIPTION = 'The gaming power of your desktop in your browser'
BUNDLE_MIMETYPE = 'application/vnd.turbulenz'
BUNDLE_PLUGINEXTENSIONS = ['tzjs', 'tzo']
BUNDLE_SIGNATURE='TBLZ'

# Usage

def usage():

    print """
Usage:

  %s --version <X.Y.Z.W> <options>""" % sys.argv[0] + """

  Generate an Info.plist for a .bundle using the properties passed in.  The
  resulting Info.plist file is written to stdout.

Options:

  --bundlename <name>            Name of bundle

  --executable <executable>      Main executable in bundle

  --version <X.Y.Z.W>            4-component version number (required)

  --description <description>    Plugin description
"""
    exit(1)

# IMPORTANT NOTE: The version number description on the
# WebPluginTypeDescription allows the site detect the plugin version
# WITHOUT loading it. DO NOT REMOVE!!!

# Overrides

args = copy.copy(sys.argv)
args.pop(0)
while len(args) > 0:
    a = args.pop(0)
    if a == '--bundlename':
        BUNDLE_NAME = args.pop(0)
    elif a == '--executable':
        BUNDLE_EXECUTABLE = args.pop(0)
    elif a == '--version':
        version = args.pop(0)
        v = version.split('.')
        digits = len(v)
        if digits < 3:
            v.append(0)
        if digits < 4:
            v.append(0)
        BUNDLE_VERSION = "%s.%s.%s" % (v[0],v[1],v[2])
        BUNDLE_FULLVERSION = "%s.%s.%s.%s" % (v[0],v[1],v[2],v[3])
        BUNDLE_SHORTVERSION = BUNDLE_VERSION # "%s.%s" % (v[0],v[1])
    elif a == '--description':
        BUNDLE_DESCRIPTION = args.pop(0)
    else:
        raise Exception("Unrecognised argument: %s" % a)

# Check we have enough parameters

if (BUNDLE_FULLVERSION is None or
    BUNDLE_VERSION is None or
    BUNDLE_SHORTVERSION is None):
    usage()

# Create

BUNDLE_FILE=BUNDLE_NAME+".plugin"

print """<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>BuildMachineOSBuild</key>
	<string>10K549</string>
	<key>CFBundleDevelopmentRegion</key>
	<string>English</string>
	<key>CFBundleExecutable</key>
	<string>""" + BUNDLE_EXECUTABLE + """</string>
	<key>CFBundleIdentifier</key>
	<string>""" + BUNDLE_ID + """</string>
	<key>CFBundleInfoDictionaryVersion</key>
	<string>6.0</string>
	<key>CFBundleName</key>
	<string>""" + BUNDLE_NAME + """</string>
	<key>CFBundlePackageType</key>
	<string>BRPL</string>
	<key>CFBundleShortVersionString</key>
	<string>""" + BUNDLE_VERSION + """</string>
	<key>CFBundleVersion</key>
	<string>""" + BUNDLE_FULLVERSION + """</string>
	<key>CFBundleSignature</key>
	<string>""" + BUNDLE_SIGNATURE + """</string>
	<key>DTCompiler</key>
	<string></string>
	<key>DTPlatformBuild</key>
	<string>10M2518</string>
	<key>DTPlatformVersion</key>
	<string>PG</string>
	<key>DTSDKBuild</key>
	<string>9L31a</string>
	<key>DTSDKName</key>
	<string>macosx10.5</string>
	<key>DTXcode</key>
	<string>0400</string>
	<key>DTXcodeBuild</key>
	<string>10M2518</string>
	<key>WebPluginDescription</key>
	<string>""" + BUNDLE_DESCRIPTION + """</string>
	<key>WebPluginMIMETypes</key>
	<dict>
		<key>""" + BUNDLE_MIMETYPE + """</key>
		<dict>
			<key>WebPluginExtensions</key>
			<array>"""
for e in BUNDLE_PLUGINEXTENSIONS:
    print "                                <string>"+e+"</string>"
print """			</array>
			<key>WebPluginTypeDescription</key>
			<string>""" + BUNDLE_NAME + """:""" + BUNDLE_FULLVERSION + """</string>
		</dict>
	</dict>
	<key>WebPluginName</key>
	<string>""" + BUNDLE_NAME + """</string>
</dict>
</plist>
"""
