#!/usr/bin/env python2.7
# Copyright 2013 oyatsukai.com

import sys
import os
import subprocess

############################################################

MANIFEST_1_ADMOB = """
        <!-- ADMOB BEGIN -->
        <activity android:name="com.google.ads.AdActivity"
                  android:configChanges="keyboard|keyboardHidden|orientation|screenLayout|uiMode|screenSize|smallestScreenSize">
        </activity>
        <!-- ADMOB END -->"""
ADMOB_PERMISSIONS = ";android.permission.INTERNET;" + \
    "android.permission.ACCESS_NETWORK_STATE"

MANIFEST_1_OPENFEINT = """
        <!-- OPENFEINT BEGIN -->
        <activity android:name="com.openfeint.internal.ui.IntroFlow"
                  android:label="IntroFlow"
                  android:configChanges="orientation|keyboardHidden"
                  android:theme="@android:style/Theme.NoTitleBar"/>
        <activity android:name="com.openfeint.api.ui.Dashboard"
                  android:label="Dashboard"
                  android:configChanges="orientation|keyboardHidden"
                  android:theme="@android:style/Theme.NoTitleBar"/>
        <activity android:name="com.openfeint.internal.ui.Settings"
                  android:label="Settings"
                  android:configChanges="orientation|keyboardHidden"
                  android:theme="@android:style/Theme.NoTitleBar"/>
        <activity android:name="com.openfeint.internal.ui.NativeBrowser"
                  android:label="NativeBrowser"
                  android:configChanges="orientation|keyboardHidden"
                  android:theme="@android:style/Theme.NoTitleBar"/>
        <!-- OPENFEINT END -->"""
OPENFEINT_PERMISSIONS = ";android.permission.INTERNET;" + \
    "android.permission.ACCESS_NETWORK_STATE;" + \
    "android.permission.WRITE_EXTERNAL_STORAGE;" + \
    "android.permission.GET_ACCOUNTS"

ZIRCONIA_PERMISSIONS = ";android.permission.READ_PHONE_STATE;" + \
    "android.permission.INTERNET"

MANIFEST_1_MOBIROO = """
        <!-- MOBIROO BEGIN -->
        <activity android:name="MobirooActivity"
                  android:configChanges="keyboardHidden|orientation">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
        <!-- MOBIROO END -->"""

MOBIROO_PERMISSIONS = ";android.permission.INTERNET" + \
    ";android.permission.READ_PHONE_STATE"             + \
    ";android.permission.ACCESS_WIFI_STATE"            + \
    ";android.permission.ACCESS_NETWORK_STATE"         + \
    ";android.permission.GET_TASKS"

MANIFEST_1_MMEDIA = """
        <!-- MMEDIA BEGIN -->
        <activity android:name="com.millennialmedia.android.MMActivity"
                  android:theme="@android:style/Theme.Translucent.NoTitleBar"
                  android:configChanges="keyboardHidden|orientation|keyboard" >
        </activity>
        <activity android:name="com.millennialmedia.android.VideoPlayer"
                  android:configChanges="keyboardHidden|orientation|keyboard" >
        </activity>
        <!-- MMEDIA END -->"""

MMEDIA_PERMISSIONS = ";android.permission.WRITE_EXTERNAL_STORAGE" + \
    ";android.permission.READ_PHONE_STATE"

MANIFEST_1_TAPIT = """
        <!-- TAPIT BEGIN -->
        <activity android:name="com.tapit.sdk.InAppWebView"/>
        <!-- TAPIT END -->"""

TAPIT_PERMISSIONS = ";android.permission.INTERNET" + \
    ";android.permission.READ_PHONE_STATE"

MANIFEST_1_MEDIBA = """
        <!-- MEDIBA BEGIN -->
        <activity android:name="mediba.ad.sdk.android.openx.MasAdClickWebview" />
        <!-- MEDIBA END -->"""

MEDIBA_PERMISSIONS = ";android.permission.INTERNET" + \
    ";android.permission.ACCESS_NETWORK_STATE"


MANIFEST_1_CHARTBOOST = """
        <!-- CHARTBOOST BEGIN -->
        <!-- (no longer requires an activity)
        <activity android:name="com.chartboost.sdk.CBDialogActivity"
                  android:configChanges="orientation|keyboard|keyboardHidden"
                  android:windowSoftInputMode="adjustResize"
                  android:theme="@android:style/Theme.Translucent"
                  android:launchMode="singleTop" >
        </activity>
        -->
        <!-- CHARTBOOST END -->"""

CHARTBOOST_PERMISSIONS = ";android.permission.INTERNET" + \
    ";android.permission.WRITE_EXTERNAL_STORAGE" + \
    ";android.permission.ACCESS_NETWORK_STATE" + \
    ";android.permission.ACCESS_WIFI_STATE"

#
#
#
def _verbose(msg):
    print "%s" % msg
def _silent(msg):
    pass
verbose = _silent
wrote = False

#
#
#
def mkdir_if_not_exists(path):
    if not os.path.exists(path):
        os.mkdir(path)

#
#
#
def replace_tags(in_string, table):
    for tag in table:
        verbose("Replacing %s with %s" % (tag, table[tag]))
        in_string = in_string.replace(tag, "%s" % table[tag])
    return in_string

#
#
#
def write_file_if_different(filename, data):
    if os.path.exists(filename):
        f = open(filename, 'rb')
        old_data = f.read()
        f.close()
        if old_data == data:
            print "File '%s' has not changed.  Not writing" \
                % os.path.basename(filename)
            return

    with open(filename, 'wb') as f:
        f.write(data)

    global wrote
    wrote = True

#
#
#
def copy_file_if_different(src, target):
    with open(src, 'rb') as in_f:
        data = in_f.read()
    write_file_if_different(target, data)

#
#
#
def write_manifest(dest, table, permissions, extras, library):

    # Create res dir if it doesn't exist

    res_dir = os.path.join(dest, 'res')
    mkdir_if_not_exists(res_dir)

    # [ MANIFEST_FRAGMENT, <permissions>, <override main activity> ]

    extras_table = {
        'admob' : [ MANIFEST_1_ADMOB, ADMOB_PERMISSIONS, False ],
        'openfeint' : [ MANIFEST_1_OPENFEINT, OPENFEINT_PERMISSIONS, False ],
        'zirconia' : [ "", ZIRCONIA_PERMISSIONS, False ],
        'mobiroo' : [ MANIFEST_1_MOBIROO, MOBIROO_PERMISSIONS, True ],
        'mmedia' : [ MANIFEST_1_MMEDIA, MMEDIA_PERMISSIONS, False ],
        'tapit' : [ MANIFEST_1_TAPIT, TAPIT_PERMISSIONS, False ],
        'mediba' : [ MANIFEST_1_MEDIBA, MEDIBA_PERMISSIONS, False ],
        'chartboost' : [ MANIFEST_1_CHARTBOOST, CHARTBOOST_PERMISSIONS, False ]
        }

    # icon

    icon_attr = 'android:icon="@drawable/icon"'
    if not table['%ICON_DIR%']:
        icon_attr = ''
    table['%ICON_ATTR%'] = icon_attr

    # Start writing

    output = os.path.join(dest, 'AndroidManifest.xml')

    data = ""

    # Header

    ########################################
    # LIBRARY
    ########################################

    if library:
        MANIFEST_LIBRARY_0 = """<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
      package="%PACKAGE_NAME%"
      android:versionCode="%VERSION_INT%"
      android:versionName="%VERSION_DOT_4%">
    <application android:label="API">
    </application>
    <uses-sdk android:minSdkVersion="%ANDROID_SDK_VERSION%" />
</manifest>"""

        data += replace_tags(MANIFEST_LIBRARY_0, table)
        write_file_if_different(output, data)
        return

    ########################################
    # APPLICATION
    ########################################

    # Write res/values

    res_values_dir = os.path.join(res_dir, 'values')

    mkdir_if_not_exists(res_values_dir)
    for x in [ 'ldpi', 'mdpi', 'hdpi' ]:
        mkdir_if_not_exists(os.path.join(res_dir, 'drawable-%s' % x))
    res_values_strings = os.path.join(res_values_dir, 'strings.xml')

    res_values_strings_data = \
        replace_tags("""<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">%APP_TITLE%</string>
</resources>
""", table)
    write_file_if_different(res_values_strings, res_values_strings_data)

    # Override main activity?

    override_main_activity = False
    for e in extras:
        override_main_activity = override_main_activity or extras_table[e][2]

    # Write manifest

    MANIFEST_0 = """<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
      package="%PACKAGE_NAME%"
      android:versionCode="%VERSION_INT%"
      android:versionName="%VERSION_DOT_4%"
      android:installLocation="auto">
    <application android:label="@string/app_name" %ICON_ATTR%>
        <activity android:name="%ACTIVITY_NAME%"
                  android:label="%APP_TITLE%"
                  android:screenOrientation="landscape"
                  android:launchMode="singleInstance"
                  android:configChanges="orientation"
                  >"""
    if not override_main_activity:
        MANIFEST_0 += """
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>"""

    MANIFEST_0 += """
        </activity>"""

    data += replace_tags(MANIFEST_0, table)

    # Extra decls

    for e in extras:
        data += extras_table[e][0]

    # End of activity

    MANIFEST_2 = """
    </application>

    <!-- SCREEN BEGIN -->
    <!-- NOTE: Kindle Fire requires largeScreens=true -->
    <supports-screens android:largeScreens="true"
                      android:normalScreens="true"
		      android:smallScreens="false"
		      android:anyDensity="true" />
    <uses-feature android:name="android.hardware.screen.landscape" />
    <!-- SCREEN END -->

    <uses-sdk android:minSdkVersion="%ANDROID_SDK_VERSION%" />"""

    data += replace_tags(MANIFEST_2, table)

    # Permissions.  Add extras and remove duplicates

    verbose("permissions: %s" % permissions)
    for e in extras:
        permissions += extras_table[e][1]
    permissions = list(set(permissions.split(';')))

    # Write permissions

    MANIFEST_3_PERMISSION_PRE  = '\n    <uses-permission android:name="'
    MANIFEST_3_PERMISSION_POST = '" />'

    for p in permissions:
        data += MANIFEST_3_PERMISSION_PRE + p + MANIFEST_3_PERMISSION_POST

    # OpenGL ES 2.0

    data += """
    <uses-feature android:glEsVersion="0x00020000" />"""

    # Footer

    MANIFEST_4 = """
</manifest>
"""
    data += MANIFEST_4

    # Conditionally write the file

    write_file_if_different(output, data)


#
#
#
def write_ant_properties(dest, dependencies, src, library, keystore, keyalias):

    ant_properties_name = os.path.join(dest, "ant.properties")
    verbose("ant.properties: %s" % ant_properties_name)

    data = ""

    data += "# generated by make_android_project.py\n"

    if library:
        data += "android.library=true\n"

    data += "includeantruntime=false\n"

    if src:
        src_rel = os.path.relpath(os.path.abspath(src), dest)
        verbose(" '%s' (src) -> '%s'" % (src, src_rel))
        data += "source.dir=%s\n" % src_rel

    i = 1
    for dep in dependencies:
        rel = os.path.relpath(dep, dest)
        verbose(" '%s' -> '%s'" % (dep, rel))
        data += "android.library.reference.%d=%s\n" % (i, rel)
        i = i + 1

    # Key info

    if keystore and not library:
        kp = keystore.split(",")
        keystore = kp[0]
        if len(kp) > 1:
            data += "key.store.password=%s\n" % kp[1]
            data += "key.alias.password=%s\n" % kp[1]
        keystore_rel = os.path.relpath(keystore, dest)
        data += "key.store=%s\n" % keystore_rel
    if keyalias and not library:
        data += "key.alias=%s\n" % keyalias

    write_file_if_different(ant_properties_name, data)
    return True

#
#
#
def copy_icon_files(dest, icon_dir):
    types = [ "hdpi", "mdpi", "ldpi" ]

    # Check for icon files

    src_dest = {}
    for i in types:
        src = os.path.join(icon_dir, "drawable-%s" % i, "icon.png")
        if not os.path.exists(src):
            print "ERROR: Failed to find '%s'" % src
            exit(1)
        src_dest[src] = os.path.join(dest, "res", "drawable-%s" % i)

    for src in src_dest:
        dest = src_dest[src]
        verbose("[ICON] %s -> %s" % (src, dest))

        mkdir_if_not_exists(dest)
        copy_file_if_different(src, os.path.join(dest, "icon.png"))

#
#
#
def run_android_project_update(dest, name, dependencies, library):

    if library:
        cmd = 'android update lib-project -p %s -t %s' \
            % (dest, 'android-16')
    else:
        cmd = 'android update project -p %s -t %s -n %s --subprojects' \
            % (dest, 'android-16', name)
        for dep in dependencies:
            rel = os.path.relpath(dep, dest)
            verbose(" '%s' -> '%s'" % (dep, rel))
            cmd += ' --library %s' % rel

    verbose("EXEC: %s" % cmd)
    return subprocess.call(cmd, shell=True)

############################################################

def usage():

    print """
  Usage:

    make_android_project --dest <dest>
                         --version <X.Y.Z>
                         --package <com.company.package>
                         --sdk-version <android-8>
                         ....
                         [options]

    make_android_project --library
                         --package <com.company.package>
                         --sdk-version <android-8>

  Options:

    -v,--verbose        - Spit out debugging information

    --dest <dir-name>   - Directory to create project in

    --version <X.Y.Z>

    --target <android-target-name>
                        - e.g. 'android-16'

    --name <project-name>
                        - e.g. 'finalfwy'

    --title <app-title>
                        - e.g. 'Final Fwy'

    --package <com.company...myapp>

    --src <src-dir>
                        - base directory of source files

    --activity <class-name>

    --sdk-version       - minSdkVersion

    --permissions "<perm1>;<perm2>;.."
                        - (optional) e.g. "com.android.vending.CHECK_LICENSE;
                          android.permission.INTERNET"

    --depends <project-location>
                        - (optional) Can use multiple times

    --icon-dir <icon-dir>
                        - (optional) Use drawable-* from <icon-dir>

    --key-store <file>  - (optional) Location of keystore

    --key-alias <alias> - (optional) Alias of key in keys store to use

    --admob             - (optional) include AdMob activity decl

    --openfeint         - (optional) include OpenFeint activity decl

    --zirconia          - (optional) include Zirconia permissions

    --mobiroo           - (optional) include mobiroo entries to manifest

    --mmedia            - (optional) include MillennialMedia manifest entries"

    --tapit             - (optional) include MillennialMedia manifest entries"

    --mediba            - (optional) include Medbia manifest entries"

    --chartboost        - (optional) include ChartBoost manifest entries"

  Example:

    make_android_project --dest java --version 3.2.5 --target 'android-16' --name 'myproj' --title 'MyProject' --package com.company.project.app --sdk-version 8 --activity MyProjectActivity

"""

def main():

    args = sys.argv
    args.pop(0)

    library = False
    dest = None
    version = None
    target = None
    name = None
    title = None
    package = None
    activity = None
    sdk_version = "8"
    icon_dir = None
    keystore = None
    keyalias = None
    src = None
    extras = []
    permissions = \
        "android.permission.WAKE_LOCK;android.permission.WRITE_SETTINGS;" + \
        "com.android.vending.CHECK_LICENSE"
    depends = []

    while len(args):
        arg = args.pop(0)

        if arg in [ "-v", "--verbose" ]:
            global verbose
            verbose = _verbose
        if "--dest" == arg:
            dest = args.pop(0)
        elif "--version" == arg:
            version = args.pop(0)
        elif "--target" == arg:
            target = args.pop(0)
        elif "--name" == arg:
            name = args.pop(0)
        elif "--title" == arg:
            title = args.pop(0)
        elif "--package" == arg:
            package = args.pop(0)
        elif "--activity" == arg:
            activity = args.pop(0)
        elif "--sdk-version" == arg:
            sdk_version = args.pop(0)
        elif "--permissions" == arg:
            permissions += ";" + args.pop(0)
        elif "--depends" == arg:
            depends.append(args.pop(0))
        elif "--icon-dir" == arg:
            icon_dir = args.pop(0)
        elif "--key-store" == arg:
            keystore = args.pop(0)
        elif "--key-alias" == arg:
            keyalias = args.pop(0)
        elif "--src" == arg:
            src = args.pop(0)
        elif "--library" == arg:
            library = True
        elif "--admob" == arg:
            extras.append('admob')
        elif "--mmedia" == arg:
            extras.append('mmedia')
        elif "--tapit" == arg:
            extras.append('tapit')
        elif "--mediba" == arg:
            extras.append('mediba')
        elif "--chartboost" == arg:
            extras.append('chartboost')
        elif "--openfeint" == arg:
            extras.append('openfeint')
        elif "--zirconia" == arg:
            extras.append('zirconia')
        elif "--mobiroo" == arg:
            extras.append('mobiroo')
        else:
            print "Error: unknown parameter: '%s'" % arg
            print ""
            usage()
            exit(1)

    # Check args

    err = False
    if dest is None:
        print "Error: no destination specified"
        err = True
    if version is None:
        print "Error: no version specified"
        err = True

    if err:
        usage()
        exit(2)

    # Version stuf

    version_int_list = [ int(i) for i in version.split('.') ] + [ 0 ]
    if len(version_int_list) != 4:
        print "Error: version string should be of the form: X.Y.Z"
        print ""
        usage()
        exit(1)

    version_int = version_int_list[3] + \
        version_int_list[2] * 100 + \
        version_int_list[1] * 10000 + \
        version_int_list[0] * 1000000
    version_dot_4 = ".".join([ str(i) for i in version_int_list])
    if 0 == version_int_list[3]:
        version_name = ".".join([ str(i) for i in version_int_list[0:3] ])
    else:
        version_name = version_dot_4

    # Template table

    table = {
        '%PACKAGE_NAME%' : package,
        '%VERSION_INT%' : version_int,
        '%VERSION_DOT_4%' : version_dot_4,
        '%ACTIVITY_NAME%' : activity,
        '%APP_TITLE%' : title,
        '%ANDROID_SDK_VERSION%' : sdk_version,
        '%ICON_DIR%' : icon_dir
        }

    verbose("TABLE: ")
    verbose("\n".join(["%s: %s" % (k, table[k]) for k in table]))
    verbose("")

    # Dir

    if not os.path.exists(dest):
        print "Error: destination directory '%s' does not exist" % dest
        print ""
        usage()
        exit(1)

    # Write manifest

    write_manifest(dest, table, permissions, extras, library)

    # Write ant.properties (dependencies)

    write_ant_properties(dest, depends, src, library, keystore, keyalias)

    # Copy icon file

    if icon_dir:
        copy_icon_files(dest, icon_dir)

    # Run 'android update project -p ... --target android-16 -n <name>
    # --library ...'

    global wrote
    if wrote:
        fullname = "%s-%s" % (name, version_name)
        if not 0 == run_android_project_update(dest, fullname, depends, library):
            return 1
    else:
        print "No project files changed, not running android project update"

    return 0

############################################################

if __name__ == "__main__":
    exit(main())
