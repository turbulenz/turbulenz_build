#!/usr/bin/env python2.7
# Copyright 2013 oyatsukai.com

import sys
import os
import subprocess

############################################################

MANIFEST_1_ANDROIDLICENSE = ""

ANDROIDLICENSE_PERMISSIONS = ";com.android.vending.CHECK_LICENSE"

MANIFEST_1_ADMOB = """
        <!-- ADMOB BEGIN -->
        <activity android:name="com.google.ads.AdActivity"
                  android:configChanges="keyboard|keyboardHidden|orientation|screenLayout|uiMode|screenSize|smallestScreenSize"/>
        <!-- ADMOB END -->"""
ADMOB_PERMISSIONS = ";android.permission.INTERNET" + \
    ";android.permission.ACCESS_NETWORK_STATE"

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
    ";android.permission.READ_PHONE_STATE"           + \
    ";android.permission.ACCESS_WIFI_STATE"          + \
    ";android.permission.ACCESS_NETWORK_STATE"       + \
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

TAPIT_PERMISSIONS = ";android.permission.INTERNET" \
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

MANIFEST_1_TAPFORTAP = "defined in write_manifest"

# some of these are optional
TAPFORTAP_PERMISSIONS = ";android.permission.INTERNET" \
    + ";android.permission.WRITE_EXTERNAL_STORAGE" \
    + ";android.permission.ACCESS_NETWORK_STATE" \
    + ";android.permission.ACCESS_WIFI_STATE" \
 #   + ";android.permission.READ_PHONE_STATE"

MANIFEST_1_HEYZAP = """
        <!-- HEYZAP BEGIN -->
        <receiver android:name="com.heyzap.sdk.PackageAddedReceiver">
          <intent-filter>
            <data android:scheme="package" />
            <action android:name="android.intent.action.PACKAGE_ADDED" />
          </intent-filter>
        </receiver>
        <!-- HEYZAP END -->"""

HEYZAP_PERMISSIONS = ";android.permission.INTERNET" \
    + ";android.permission.ACCESS_NETWORK_STATE"

MANIFEST_1_OPENKIT = """
        <!-- OPENKIT BEGIN -->
        <activity
            android:name="io.openkit.OKLoginActivity"
            android:theme="@style/Theme.Transparent" />
        <activity android:name="io.openkit.leaderboards.OKLeaderboardsActivity" />
        <activity android:name="io.openkit.leaderboards.OKScoresActivity" />
        <activity android:name="io.openkit.user.OKUserProfileActivity" />
        <activity android:name="io.openkit.facebook.LoginActivity" />
        <meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/fb_app_id" />
        <!-- OPENKIT END -->"""

OPENKIT_PERMISSIONS = ";android.permission.INTERNET"

MANIFEST_1_FACEBOOK = """
        <!-- FACEBOOK BEGIN -->
        <activity android:name="com.facebook.LoginActivity" />
        <meta-data android:name="com.facebook.sdk.ApplicationId" android:value="@string/fb_app_id" />
        <!-- FACEBOOK END -->"""

FACEBOOK_PERMISSIONS = ";android.permission.INTERNET"

MANIFEST_1_AMAZON_BILLING = """
        <!-- AMAZON BILLING BEGIN -->
        <receiver android:name = "com.amazon.inapp.purchasing.ResponseReceiver" >
         <intent-filter>
          <action
           android:name="com.amazon.inapp.purchasing.NOTIFY"
           android:permission="com.amazon.inapp.purchasing.Permission.NOTIFY" />
         </intent-filter>
        </receiver>
        <!-- AMAZON BILLING END -->"""

AMAZON_BILLING_PERMISSIONS = ""

MANIFEST_1_APPAYABLE = """
        <!-- APPAYABLE BEGIN -->
        <service android:name="org.OpenUDID.OpenUDID_service">
         <intent-filter>
          <action android:name="org.OpenUDID.GETUDID" />
         </intent-filter>
        </service>
        <!-- APPAYABLE END -->"""

APPAYABLE_PERMISSIONS = ""

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
def write_manifest(dest, table, permissions, intent_filters, meta,
                   extras, library, resource_strings, options):

    MANIFEST_1_TAPFORTAP = """
        <!-- TAPFORTAP BEGIN -->
        <activity android:name="com.tapfortap.TapForTapActivity" """
    if options['landscape']:
        MANIFEST_1_TAPFORTAP += """
                  android:screenOrientation="landscape"
                  android:configChanges="orientation" """
    MANIFEST_1_TAPFORTAP += """/>
        <!-- TAPFORTAP END -->"""

    # Create res dir if it doesn't exist

    res_dir = os.path.join(dest, 'res')
    mkdir_if_not_exists(res_dir)

    # [ MANIFEST_FRAGMENT, <permissions>, <override main activity> ]

    extras_table = {
        'androidlicense':
        [ MANIFEST_1_ANDROIDLICENSE, ANDROIDLICENSE_PERMISSIONS, False ],
        'admob'      : [ MANIFEST_1_ADMOB, ADMOB_PERMISSIONS, False ],
        'zirconia'   : [ "", ZIRCONIA_PERMISSIONS, False ],
        'mobiroo'    : [ MANIFEST_1_MOBIROO, MOBIROO_PERMISSIONS, True ],
        'mmedia'     : [ MANIFEST_1_MMEDIA, MMEDIA_PERMISSIONS, False ],
        'tapit'      : [ MANIFEST_1_TAPIT, TAPIT_PERMISSIONS, False ],
        'mediba'     : [ MANIFEST_1_MEDIBA, MEDIBA_PERMISSIONS, False ],
        'chartboost' : [ MANIFEST_1_CHARTBOOST, CHARTBOOST_PERMISSIONS, False ],
        'tapfortap'  : [ MANIFEST_1_TAPFORTAP, TAPFORTAP_PERMISSIONS, False ],
        'heyzap'     : [ MANIFEST_1_HEYZAP, HEYZAP_PERMISSIONS, False ],
        'openkit'    : [ MANIFEST_1_OPENKIT, OPENKIT_PERMISSIONS, False ],
        'facebook'   : [ MANIFEST_1_FACEBOOK, FACEBOOK_PERMISSIONS, False ],
        'amazon-billing':
        [ MANIFEST_1_AMAZON_BILLING, AMAZON_BILLING_PERMISSIONS, False ],
        'appayable'  : [ MANIFEST_1_APPAYABLE, APPAYABLE_PERMISSIONS, False ]
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
    <string name="app_name">%APP_TITLE%</string>""", table)
    for k, v in resource_strings.iteritems():
        res_values_strings_data += '\n    <string name="%s">%s</string>' \
            % (k, v)
    res_values_strings_data += """
</resources>
"""

    write_file_if_different(res_values_strings, res_values_strings_data)

    # Override main activity?  This should happen either if the
    # --no-launcher flag was given, or if one of the extras wants to
    # be the main activity.

    override_main_activity = options['nolauncher']
    if not override_main_activity:
        for e in extras:
            override_main_activity = \
                override_main_activity or extras_table[e][2]

    # Write manifest

    MANIFEST_0 = """<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
      package="%PACKAGE_NAME%"
      android:versionCode="%VERSION_INT%"
      android:versionName="%VERSION_DOT_4%"
      android:installLocation="auto">
    <application android:label="@string/app_name" %ICON_ATTR%"""

    if options['backup_agent']:
        class_key = options['backup_agent'].split(',')
        MANIFEST_0 += """
                 android:backupAgent=""" + '"%s"' % class_key[0]
        MANIFEST_0 += """>
        <meta-data android:name="com.google.android.backup.api_key"
                   android:value=""" + '"%s" />' % class_key[1]
    else:
        MANIFEST_0 += ">"

    MANIFEST_0 += """
        <activity android:name="%ACTIVITY_NAME%"
                  android:label="%APP_TITLE%"
                  android:launchMode="singleTask" """

    if options['landscape']:
        MANIFEST_0 += """
                  android:screenOrientation="sensorLandscape"
                  android:configChanges="orientation|screenSize" """

    MANIFEST_0 += """
                  >"""
    if not override_main_activity:
        MANIFEST_0 += """
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>"""

    if intent_filters:
        with open(intent_filters, "rb") as intent_f:
            MANIFEST_0 += "\n"
            MANIFEST_0 += intent_f.read()

    for k,v in meta.items():
        MANIFEST_0 += """
            <meta-data android:name="%s" android:value="%s" />""" % (k, v)

    MANIFEST_0 += """
        </activity>"""

    for a in options['activity_files']:
        with open(a, "rb") as a_f:
            MANIFEST_0 += "\n"
            MANIFEST_0 += a_f.read()

    for a in options['launcher_activities']:
        activity_class = a[0]
        activity_label = a[1]
        activity_icon = a[2]
        MANIFEST_0 += """
        <activity """
        MANIFEST_0 += "android:name=\"%s\" android:label=\"%s\" " \
                      % (activity_class, activity_label)
        MANIFEST_0 += ("android:icon=\"@drawable/%s\"" % activity_icon) + """
                  >
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
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
    optional_types = [ "xhdpi" ]

    # Check for icon files

    src_dest = {}
    for i in types:
        src = os.path.join(icon_dir, "drawable-%s" % i, "icon.png")
        if not os.path.exists(src):
            print "ERROR: Failed to find '%s'" % src
            exit(1)
        src_dest[src] = os.path.join(dest, "res", "drawable-%s" % i)
    for i in optional_types:
        src = os.path.join(icon_dir, "drawable-%s" % i, "icon.png")
        if os.path.exists(src):
            src_dest[src] = os.path.join(dest, "res", "drawable-%s" % i)

    for src in src_dest:
        dest = src_dest[src]
        verbose("[ICON] %s -> %s" % (src, dest))

        mkdir_if_not_exists(dest)
        copy_file_if_different(src, os.path.join(dest, "icon.png"))

#
#
#
def copy_icon_single_file(dest, icon_file):
    dest = os.path.join(dest, "res", "drawable")
    mkdir_if_not_exists(dest)

    verbose("[ICON] %s -> %s" % (icon_file, dest))

    copy_file_if_different(icon_file, os.path.join(dest, "icon.png"))

#
#
#
def _copy_files_to_dir(dest, file_list, tag="[FILE]"):
    mkdir_if_not_exists(dest)
    for f in file_list:
        f_base = os.path.split(f)[1]
        f_dest = os.path.join(dest, f_base)
        _verbose("%s %s -> %s" % (tag, f, f_dest))
        copy_file_if_different(f, f_dest)

#
def copy_xml_files(dest, xml_files):
    dest_dir = os.path.join(dest, "res", "xml")
    _copy_files_to_dir(dest_dir, xml_files, "[XML]")

#
def copy_value_files(dest, value_files):
    dest_dir = os.path.join(dest, "res", "values")
    _copy_files_to_dir(dest_dir, value_files, "[VALUE]")

#
def copy_layout_files(dest, layout_files):
    dest_dir = os.path.join(dest, "res", "layout")
    _copy_files_to_dir(dest_dir, layout_files, "[LAYOUT]")

#
def copy_drawable_files(dest, drawable_files):
    dest_dir = os.path.join(dest, "res", "drawable")
    _copy_files_to_dir(dest_dir, drawable_files, "[DRAWABLE]")

#
def copy_asset_files(dest, asset_files):
    dest_dir = os.path.join(dest, "assets")
    _copy_files_to_dir(dest_dir, assets, "[ASSET]")

#
def copy_png_asset_files(dest, png_asset_files):
    dest_dir = os.path.join(dest, "assets")
    _copy_files_to_dir(dest_dir, png_asset_files, "[ASSET(PNG)]")

#
#
#
def run_android_project_update(dest, name, dependencies, sdk_root, library):

    android = "android"
    if not sdk_root is None:
        android = sdk_root + "/tools/android"

    if library:
        cmd = '%s update lib-project -p %s -t %s' \
            % (android, dest, 'android-16')
    else:
        cmd = '%s update project -p %s -t %s -n %s --subprojects' \
            % (android, dest, 'android-16', name)
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
                         --version <X.Y.Z[.W]>
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

    --version <X.Y.Z[.W]>

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

    --launcher-activity <class-name>,<label>,<icon-file>
                        - (optional) add a basic decl for a launchable activity
                          using the given icon.

    --sdk-version       - minSdkVersion

    --permissions "<perm1>;<perm2>;.."
                        - (optional) e.g. "com.android.vending.CHECK_LICENSE;
                          android.permission.INTERNET"

    --resource-string name,value
                        - (optional) add a string resource to the APK

    --intent-filters <xml file>
                        - (optional) file with intent filters to add to main
                          activity

    --no-launcher       - Remove the main LAUNCHER intent so that no launcher
                          icon is created for the app

    --activity-decl <xml file>
                        - (optional) file with an activity in it

    --backup-agent <class>,<appkey>
                        - (optional) Enable backup agent with the given class
                          and key

    --meta <key>:<value>
                        - (optional) add a meta data key-value pair to the
                          main activity

    --depends <project-location>
                        - (optional) Can use multiple times

    --icon-dir <icon-dir>
                        - (optional) Use drawable-* from <icon-dir>

    --icon-file <icon-file>
                        - (optional) Use specific file as icon

    --key-store <file>  - (optional) Location of keystore

    --key-alias <alias> - (optional) Alias of key in keys store to use

    --xml <file>        - (optional) .xml file to copy to res/xml/

    --value <file>      - (optional) .xml file to copy to res/values/

    --layout <file>     - (optional) .xml file to copy to res/layout/

    --drawable <file>   - (optional) file to copy to res/drawable/

    --asset <file>      - (optional) asset file to copy to assets

    --png-asset <file>  - (optional) asset file with .png extension

    --android-sdk       - (optional) root of android SDK (if not in path)

    --android-licensing - (optional) code for android licensing

    --admob             - (optional) include AdMob activity decl

    --zirconia          - (optional) include Zirconia permissions

    --mobiroo           - (optional) include mobiroo entries to manifest

    --mmedia            - (optional) include MillennialMedia manifest entries

    --tapit             - (optional) include MillennialMedia manifest entries

    --mediba            - (optional) include Medbia manifest entries

    --chartboost        - (optional) include ChartBoost manifest entries

    --tapfortap         - (optional) include TapForTap manifest entries

    --heyzap            - (optional) include HeyZap manifest entries

    --appayable         - (optional) include Appayable manifest entries

    --openkit           - (optional) include OpenKit manifest entries

    --amazon-billing    - (optional) include Amazon Billing manifest entries

    --facebook          - (optional) include facebook entries

  Example:

    make_android_project --dest java --version 3.2.5 --target 'android-16' --name 'myproj' --title 'MyProject' --package com.company.project.app --sdk-version 8 --activity MyProjectActivity

"""

def main():

    args = sys.argv
    args.pop(0)

    library = False
    dest = None
    android_sdk_root = None
    version = None
    target = None
    name = None
    title = None
    package = None
    activity = None
    sdk_version = "8"
    icon_dir = None
    icon_file = None
    keystore = None
    keyalias = None
    src = None
    extras = []
    permissions = \
        "android.permission.WAKE_LOCK" \
        # ";android.permission.WRITE_SETTINGS"

    intent_filters = None
    meta = {}
    depends = []
    resource_strings = {}
    xml_files = []
    value_files = []
    layout_files = []
    drawable_files = []
    asset_files = []
    png_asset_files = []
    options = {
        'landscape': True,
        'activity_files': [],
        'backup_agent': None,
        'nolauncher': False,
        'launcher_activities': [],
        }

    def add_meta(kv):
        colon_idx = kv.find(':')
        if -1 == colon_idx:
            print "Badly formed meta data: %s" % kv
            usage()
            exit(1)
        k = kv[:colon_idx]
        v = kv[colon_idx+1:]
        print "Saw meta data: KEY: %s, VALUE: %s" % (k, v)
        meta[k] = v

    def add_launcher_activity(ai):
        parts = ai.split(',')
        if 3 != len(parts):
            print "Badly formated launcher activity: %s" % ai
            usage()
            exit(1)

        a = parts[0]
        l = parts[1]
        i = parts[2]
        drawable_files.append(i)

        i_base = os.path.splitext(os.path.split(i)[1])[0]
        options['launcher_activities'].append((a,l,i_base))

    while len(args):
        arg = args.pop(0)

        if arg in [ "-v", "--verbose" ]:
            global verbose
            verbose = _verbose
        if "--dest" == arg:
            dest = args.pop(0)
        elif "--android-sdk" == arg:
            android_sdk_root = args.pop(0)
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
        elif "--launcher-activity" == arg:
            add_launcher_activity(args.pop(0))
        elif "--sdk-version" == arg:
            sdk_version = args.pop(0)
        elif "--permissions" == arg:
            permissions += ";" + args.pop(0)
        elif "--resource-string" == arg:
            res_kv = args.pop(0).split(",")
            resource_strings[res_kv[0]] = res_kv[1]
        elif "--intent-filters" == arg:
            intent_filters = args.pop(0)
        elif "--no-launcher" == arg:
            options['nolauncher'] = True
        elif "--activity-decl" == arg:
            options['activity_files'].append(args.pop(0))
        elif "--backup-agent" == arg:
            options['backup_agent'] = args.pop(0)
        elif "--meta" == arg:
            add_meta(args.pop(0))
        elif "--depends" == arg:
            depends.append(args.pop(0))
        elif "--icon-dir" == arg:
            icon_dir = args.pop(0)
            icon_file = None
        elif "--icon-file" == arg:
            icon_dir = None
            icon_file = args.pop(0)
        elif "--key-store" == arg:
            keystore = args.pop(0)
        elif "--key-alias" == arg:
            keyalias = args.pop(0)
        elif "--xml" == arg:
            xml_files.append(args.pop(0))
        elif "--value" == arg:
            value_files.append(args.pop(0))
        elif "--layout" == arg:
            layout_files.append(args.pop(0))
        elif "--drawable" == arg:
            drawable_files.append(args.pop(0))
        elif "--asset" == arg:
            asset_files.append(args.pop(0))
        elif "--png-asset" == arg:
            png_asset_files.append(args.pop(0))
        elif "--no-landscape" == arg:
            options['landscape'] = False
        elif "--src" == arg:
            src = args.pop(0)
        elif "--library" == arg:
            library = True
        elif "--android-licensing" == arg:
            extras.append("androidlicense")
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
        elif "--tapfortap" == arg:
            extras.append('tapfortap')
        elif "--heyzap" == arg:
            extras.append('heyzap')
        elif "--appayable" == arg:
            extras.append('appayable')
        elif "--zirconia" == arg:
            extras.append('zirconia')
        elif "--mobiroo" == arg:
            extras.append('mobiroo')
        elif "--openkit" == arg:
            extras.append('openkit')
            extras.append('facebook')
        elif "--facebook" == arg:
            extras.append('facebook')
        elif "--amazon-billing" == arg:
            extras.append('amazon-billing')
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

    version_int_list = [ int(i) for i in version.split('.') ]
    if len(version_int_list) < 3:
        print "Error: version string should be of the form: X.Y.Z[.W]"
        print ""
        usage()
        exit(1)
    while len(version_int_list) < 4:
        version_int_list.append(0)

    version_int = version_int_list[3] + \
        version_int_list[2] * 100 + \
        version_int_list[1] * 10000 + \
        version_int_list[0] * 1000000
    version_dot_4 = ".".join([ str(i) for i in version_int_list])

    # Template table

    table = {
        '%PACKAGE_NAME%' : package,
        '%VERSION_INT%' : version_int,
        '%VERSION_DOT_4%' : version_dot_4,
        '%ACTIVITY_NAME%' : activity,
        '%APP_TITLE%' : title,
        '%ANDROID_SDK_VERSION%' : sdk_version,
        '%ICON_DIR%' : icon_dir or icon_file
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

    write_manifest(dest, table, permissions, intent_filters, meta,
                   extras, library, resource_strings, options)

    # Write ant.properties (dependencies)

    write_ant_properties(dest, depends, src, library, keystore, keyalias)

    # Copy icon file

    if icon_dir:
        copy_icon_files(dest, icon_dir)
    elif icon_file:
        copy_icon_single_file(dest, icon_file)

    # Copy xml files

    if 0 != len(xml_files):
        copy_xml_files(dest, xml_files)

    # Copy value files

    if 0 != len(value_files):
        copy_value_files(dest, value_files)

    # Copy layout files

    if 0 != len(layout_files):
        copy_layout_files(dest, layout_files)

    # Copy drawable files

    if 0 != len(drawable_files):
        copy_drawable_files(dest, drawable_files)

    # Copy asset files

    if 0 != len(asset_files):
        copy_asset_files(dest, asset_files)
    if 0 != len(png_asset_files):
        copy_png_asset_files(dest, png_asset_files)

    # Run 'android update project -p ... --target android-16 -n <name>
    # --library ...'

    global wrote
    if wrote:
        fullname = "%s-%s" % (name, version)
        if not 0 == run_android_project_update(dest, fullname, depends,
                                               android_sdk_root, library):
            return 1
    else:
        print "No project files changed, not running android project update"

    return 0

############################################################

if __name__ == "__main__":
    exit(main())
