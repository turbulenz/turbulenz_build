#!/usr/bin/env python2.7
# Copyright 2013 oyatsukai.com

import sys
import os
import subprocess

############################################################

MANIFEST_1_ANDROIDLICENSE = ""

ANDROIDLICENSE_PERMISSIONS = ";com.android.vending.CHECK_LICENSE"

MANIFEST_1_ACRA = """
        <!-- ACRA BEGIN -->
        <activity android:name="org.acra.CrashReportDialog"
            android:theme="@android:style/Theme.Dialog"
            android:launchMode="singleInstance"
            android:excludeFromRecents="true"
            android:finishOnTaskLaunch="true" />
        <!-- ACRA END -->"""
ACRA_PERMISSIONS = ""

MANIFEST_1_ADMOB = """
        <!-- ADMOB BEGIN -->
        <activity android:name="com.google.android.gms.ads.AdActivity"
                  android:configChanges="keyboard|keyboardHidden|orientation|screenLayout|uiMode|screenSize|smallestScreenSize"/>
       <meta-data android:name="com.google.android.gms.version"
           android:value="@integer/google_play_services_version"/>
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
        <activity android:name="com.chartboost.sdk.CBImpressionActivity"
                  android:excludeFromRecents="true"
                  android:theme="@android:style/Theme.Translucent.NoTitleBar" />
        <!-- CHARTBOOST END -->"""

CHARTBOOST_PERMISSIONS = ";android.permission.INTERNET" + \
    ";android.permission.ACCESS_NETWORK_STATE"

    # ";android.permission.WRITE_EXTERNAL_STORAGE" + \
    # ";android.permission.ACCESS_WIFI_STATE"

MANIFEST_1_TAPFORTAP = "defined in write_manifest"

# some of these are optional
TAPFORTAP_PERMISSIONS = ";android.permission.INTERNET" \
    + ";android.permission.WRITE_EXTERNAL_STORAGE" \
    + ";android.permission.ACCESS_NETWORK_STATE" \
    + ";android.permission.ACCESS_WIFI_STATE" \
 #   + ";android.permission.READ_PHONE_STATE"

MANIFEST_1_HEYZAP = """
        <!-- HEYZAP BEGIN -->
        <activity android:name="com.heyzap.sdk.ads.HeyzapInterstitialActivity"
                  android:configChanges="keyboardHidden|orientation|screenSize|smallestScreenSize" />
        <activity android:name="com.heyzap.sdk.ads.HeyzapVideoActivity"
                  android:configChanges="keyboardHidden|orientation|screenSize|smallestScreenSize" />
        <receiver android:name="com.heyzap.sdk.ads.PackageAddedReceiver">
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

OPENKIT_PERMISSIONS = ";android.permission.INTERNET" \
    + ";android.permission.GET_ACCOUNTS"

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

MANIFEST_1_GAMECIRCLE = """
        <!-- AMAZON GAMECIRCLE BEGINS -->
        <activity
             android:name="com.amazon.ags.html5.overlay.GameCircleUserInterface"
             android:theme="@style/GCOverlay" android:hardwareAccelerated="false">
        </activity>
        <activity
             android:name="com.amazon.identity.auth.device.authorization.AuthorizationActivity"
             android:theme="@android:style/Theme.NoDisplay"
             android:allowTaskReparenting="true"
             android:launchMode="singleTask">
          <intent-filter>
            <action android:name="android.intent.action.VIEW" />
            <category android:name="android.intent.category.DEFAULT" />
            <category android:name="android.intent.category.BROWSABLE" />
            <data
              android:host="%PACKAGE_NAME%"
              android:scheme="amzn" />
          </intent-filter>
        </activity>
        <activity
             android:name="com.amazon.ags.html5.overlay.GameCircleAlertUserInterface"
             android:theme="@style/GCAlert" android:hardwareAccelerated="false">
        </activity>
        <receiver
          android:name="com.amazon.identity.auth.device.authorization.PackageIntentReceiver"
          android:enabled="true" >
          <intent-filter>
            <action android:name="android.intent.action.PACKAGE_INSTALL" />
            <action android:name="android.intent.action.PACKAGE_ADDED" />
            <data android:scheme="package" />
          </intent-filter>
        </receiver>
        <!-- AMAZON GAMECIRCLE ENDS -->"""
GAMECIRCLE_PERMISSIONS = ";android.permission.INTERNET" + \
    ";android.permission.ACCESS_NETWORK_STATE"

FLURRY_PERMISSIONS = ";android.permission.INTERNET" \
    + ";android.permission.ACCESS_NETWORK_STATE"

MANIFEST_1_NATIVECRASHHANDLER = """
        <!-- NATIVECRASHHANDLER BEGIN -->
        <activity
             android:name="com.github.nativehandler.NativeCrashActivity"
             android:configChanges="keyboard|keyboardHidden|orientation"
             android:exported="false"
             android:process=":CrashHandler"
             android:stateNotNeeded="true"
             android:theme="@android:style/Theme.Translucent.NoTitleBar">
        </activity>
        <!-- NATIVECRASHHANDLER END -->"""

MANIFEST_1_APPAYABLE = """
        <!-- APPAYABLE BEGIN -->
        <service android:name="org.OpenUDID.OpenUDID_service">
         <intent-filter>
          <action android:name="org.OpenUDID.GETUDID" />
         </intent-filter>
        </service>
        <!-- APPAYABLE END -->"""
APPAYABLE_PERMISSIONS = ""

MANIFEST_1_ADLOOPER = """
        <!-- ADLOOPER BEGIN -->
        <!-- (OLD) -->
        <receiver android:name="com.kiwi.ads.service.AdInstallReceiver">
         <intent-filter>
          <action android:name="android.intent.action.PACKAGE_ADDED" />
          <action android:name="android.intent.action.PACKAGE_REMOVED" />
          <data android:scheme="package" />
         </intent-filter>
        </receiver>
        <receiver
             android:name="com.kiwi.ads.service.InstallReferrerReceiver"
             android:exported="true"
             >
         <intent-filter>
          <action android:name="com.android.vending.INSTALL_REFERRER" />
         </intent-filter>
        </receiver>
        <!-- (OLD END) -->

        <!-- (FROM PLAYHAVEN - copied from project manifest since -->
        <!--  manifestmerger doesn't seem to work)                -->
        <activity android:configChanges="orientation|keyboardHidden|screenSize" android:name="com.playhaven.android.view.FullScreen" android:theme="@android:style/Theme.Translucent.NoTitleBar" android:windowSoftInputMode="adjustResize">
            <!-- Support FullScreen.createIntent -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW"/>
                <category android:name="android.intent.category.DEFAULT"/>
            </intent-filter>
            <!-- Support Uri.parse -->
            <intent-filter>
                <action android:name="android.intent.action.VIEW"/>
                <category android:name="android.intent.category.DEFAULT"/>
                <data android:host="localhost" android:pathPattern="/full" android:scheme="playhaven"/>
            </intent-filter>
        </activity>

        <receiver android:name="com.playhaven.android.push.PushReceiver">
            <intent-filter>
                <action android:name="android.intent.action.VIEW"/>
                <category android:name="com.playhaven.android"/>
            </intent-filter>
        </receiver>
        <!-- (FROM PLAYHAVEN END) -->

        <activity android:name="com.google.android.gms.ads.AdActivity" android:configChanges="keyboard|keyboardHidden|orientation|screenLayout|uiMode|screenSize|smallestScreenSize"/>
        <activity android:name="com.greystripe.sdk.GSFullscreenActivity" android:configChanges="keyboard|keyboardHidden|orientation|screenSize" />
        <activity android:name="com.mdotm.android.view.MdotMActivity" android:launchMode="singleTop"/>
        <activity android:name="com.mdotm.android.mraid.MdotmMraidActivity" android:configChanges="keyboardHidden|orientation" android:theme="@android:style/Theme.Translucent.NoTitleBar" />
        <activity android:name="com.mdotm.android.vast.VastInterstitialActivity" android:configChanges="keyboardHidden|orientation" android:theme="@android:style/Theme.Translucent.NoTitleBar" />
        <activity android:name="com.chartboost.sdk.CBImpressionActivity" android:excludeFromRecents="true" android:theme="@android:style/Theme.Translucent.NoTitleBar" android:configChanges="keyboard|keyboardHidden|orientation|screenSize"  />
        <activity android:name="com.mopub.mobileads.MoPubActivity" android:configChanges="keyboardHidden|orientation"/>
        <activity android:name="com.mopub.mobileads.MraidActivity" android:configChanges="keyboardHidden|orientation"/>
        <activity android:name="com.mopub.mobileads.MraidBrowser" android:configChanges="keyboardHidden|orientation"/>
        <activity android:name="com.mopub.mobileads.MraidVideoPlayerActivity" android:configChanges="keyboardHidden|orientation"/>
        <!-- ADLOOPER END -->"""
ADLOOPER_PERMISSIONS = ";android.permission.INTERNET" + \
                       ";android.permission.READ_PHONE_STATE" + \
                       ";android.permission.ACCESS_NETWORK_STATE" + \
                       ";android.permission.GET_ACCOUNTS" + \
                       ";android.permission.WRITE_EXTERNAL_STORAGE"

MANIFEST_1_PLAYHAVEN = """
        <!-- PLAYHAVEN BEGIN -->
        <activity
             android:name="com.playhaven.src.publishersdk.content.PHContentView"
             android:theme="@android:style/Theme.Dialog"
             android:windowSoftInputMode="adjustResize">
        </activity>
        <!-- PLAYHAVEN END -->"""
PLAYHAVEN_PERMISSIONS = ";android.permission.INTERNET" + \
                        ";android.permission.READ_PHONE_STATE" + \
                        ";android.permission.ACCESS_NETWORK_STATE"

MANIFEST_1_GREYSTRIPE = """
        <!-- GREYSTRIPE BEGIN -->
        <activity
             android:name="com.greystripe.sdk.GSFullscreenActivity"
             android:configChanges="keyboard|keyboardHidden|orientation|screenSize">
        </activity>
        <!-- GREYSTRIPE END -->"""
GREYSTRIPE_PERMISSIONS = PLAYHAVEN_PERMISSIONS

MANIFEST_1_MDOTM = """
        <!-- MDOTM BEGIN -->
        <activity
             android:name="com.mdotm.android.view.MdotMActivity"
             android:screenOrientation="landscape"
             android:launchMode="singleTop"/>
        <!-- MDOTM END -->"""
MDOTM_PERMISSIONS = GREYSTRIPE_PERMISSIONS

# Expansion Pack Stuff

MANIFEST_1_EXPANSION = """
        <!-- Expansion Pack BEGIN -->
        <service android:name="com.oyatsukai.core.expansionservice" />
        <receiver android:name="com.oyatsukai.core.expansionalarmreceiver" />
        <!-- Expansion Pack END -->"""

EXPANSION_PERMISSIONS = \
    ";com.android.vending.CHECK_LICENSE" + \
    ";android.permission.INTERNET" + \
    ";android.permission.WAKE_LOCK" + \
    ";android.permission.ACCESS_NETWORK_STATE" + \
    ";android.permission.ACCESS_WIFI_STATE" + \
    ";android.permission.WRITE_EXTERNAL_STORAGE"

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
def write_manifest(dest, table, permissions, intent_filters, meta, app_meta,
                   extras, library, resource_strings, options):

    target = options['android-target']
    target_num = int(target.split('-')[1])

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
        'acra': [ MANIFEST_1_ACRA, ACRA_PERMISSIONS, False ],
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
        'gamecircle' : [ MANIFEST_1_GAMECIRCLE, GAMECIRCLE_PERMISSIONS, False ],
        'flurry'     : [ "", FLURRY_PERMISSIONS, False ],
        'nativecrashhandler' : [ MANIFEST_1_NATIVECRASHHANDLER, "", False ],
        'appayable'  : [ MANIFEST_1_APPAYABLE, APPAYABLE_PERMISSIONS, False ],
        'adlooper'   : [ MANIFEST_1_ADLOOPER, ADLOOPER_PERMISSIONS, False ],
        'playhaven'  : [ MANIFEST_1_PLAYHAVEN, PLAYHAVEN_PERMISSIONS, False ],
        'greystripe' : [ MANIFEST_1_GREYSTRIPE, GREYSTRIPE_PERMISSIONS, False ],
        'mdotm'      : [ MANIFEST_1_MDOTM, MDOTM_PERMISSIONS, False ],
        'expansion'  : [ MANIFEST_1_EXPANSION, EXPANSION_PERMISSIONS, False ],
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

    if target_num >= 21:
        MANIFEST_0 += """
                 android:isGame="true" """

    if table['%APPLICATION_NAME%']:
        MANIFEST_0 += """
                 android:name="%APPLICATION_NAME%" """

    if options['debug']:
        MANIFEST_0 += """
                 android:debuggable="true" """

    if options['banner']:
        MANIFEST_0 += """
                 android:banner="@drawable/banner" """

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
                  android:launchMode="singleTask"
                  android:configChanges="orientation|screenSize|keyboard|keyboardHidden|navigation|uiMode|touchscreen|smallestScreenSize" """
    if options['landscape']:
        MANIFEST_0 += """
                  android:screenOrientation=""" +'"'+options['landscape']+'"'

    MANIFEST_0 += """
                  >
            <meta-data android:name="isGame" android:value="true" />"""
    if not override_main_activity:
        MANIFEST_0 += """
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
                <category android:name="android.intent.category.LEANBACK_LAUNCHER" />
                <category android:name="tv.ouya.intent.category.GAME"/>
            </intent-filter>"""

    if intent_filters:
        with open(intent_filters, "rb") as intent_f:
            MANIFEST_0 += "\n"
            MANIFEST_0 += intent_f.read()

    MANIFEST_0 += options['activity_extra_code']

    for k,v in meta.items():
        MANIFEST_0 += """
            <meta-data android:name="%s" android:value="%s" />""" % (k, v)

    MANIFEST_0 += """
        </activity>"""

    for a in options['activity_files']:
        with open(a, "rb") as a_f:
            MANIFEST_0 += "\n"
            MANIFEST_0 += a_f.read()

    # Activities for the home screen

    for a in options['launcher_activities']:
        activity_class = a[0]
        activity_label = a[1]
        activity_icon = a[2]
        MANIFEST_0 += """
        <activity """
        MANIFEST_0 += "android:name=\"%s\" android:label=\"%s\" " \
                      % (activity_class, activity_label)
        if activity_icon:
            MANIFEST_0 += ("android:icon=\"@drawable/%s\"" % activity_icon)

        MANIFEST_0 += """
                  >
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>"""

    # Meta data in 'activity' tag

    for k,v in app_meta.items():
        MANIFEST_0 += """
        <meta-data android:name="%s" android:value="%s" />""" % (k, v)

    # Our install referrer filter takes priority over any later ones

    referrer_listener = options['install-referrer']
    if referrer_listener:
        MANIFEST_0 += """
        <receiver android:name="%s" android:exported="true">
           <intent-filter>
               <action android:name="com.android.vending.INSTALL_REFERRER" />
           </intent-filter>
        </receiver>""" % referrer_listener

    data += replace_tags(MANIFEST_0, table)

    # Extra decls

    for e in extras:
        data += replace_tags(extras_table[e][0], table)

    # End of application

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

    if options['gamepad']:
        MANIFEST_2 += """
    <uses-feature android:name="android.hardware.gamepad" android:required="false"/>"""

    if not options['require-touch']:
        MANIFEST_2 += """
    <uses-feature android:name="android.hardware.touchscreen" android:required="false" />"""

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
def write_ant_properties(dest, dependencies, src, library, keystore, keyalias,
                         options):

    ant_properties_name = os.path.join(dest, "ant.properties")
    verbose("ant.properties: %s" % ant_properties_name)

    data = ""

    data += "# generated by make_android_project.py\n"

    if library:
        data += "android.library=true\n"

    data += "includeantruntime=false\n"

    if src:
        src_rel = [ os.path.relpath(os.path.abspath(s), dest) for s in src ]
        verbose(" '%s' (src) -> '%s'" % (src, src_rel))
        data += "source.dir=%s\n" % ";".join(src_rel)

    i = 1
    for dep in dependencies:
        rel = os.path.relpath(dep, dest)
        verbose(" '%s' -> '%s'" % (dep, rel))
        data += "android.library.reference.%d=%s\n" % (i, rel)
        i = i + 1

    # Proguard

    proguard_file = options['proguard']
    if proguard_file:
        verbose("PROGUARD: %s" % proguard_file)
        proguard_rel = os.path.relpath(proguard_file, dest)
        verbose("PROGUARD: rel: %s" % proguard_rel)
        data += \
            "proguard.config=${sdk.dir}/tools/proguard/proguard-android.txt:%s\n"\
            % proguard_rel

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
def copy_drawable_files_with_name(dest, root_dir, filename):
    types = [ ]
    optional_types = [ "hdpi", "mdpi", "ldpi", "xhdpi", "xxhdpi" ]

    # Check for files

    src_dest = {}
    for i in types:
        src = os.path.join(root_dir, "drawable-%s" % i, filename)
        if not os.path.exists(src):
            print "ERROR: Failed to find '%s'" % src
            exit(1)
        src_dest[src] = os.path.join(dest, "res", "drawable-%s" % i)
    for i in optional_types:
        src = os.path.join(root_dir, "drawable-%s" % i, filename)
        if os.path.exists(src):
            src_dest[src] = os.path.join(dest, "res", "drawable-%s" % i)

    for src in src_dest:
        dest = src_dest[src]
        verbose("[DRAWABLE] %s -> %s" % (src, dest))

        mkdir_if_not_exists(dest)
        copy_file_if_different(src, os.path.join(dest, filename))

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
def _copy_files_to_dir(dest, file_list, tag="[FILE]", ext=""):
    mkdir_if_not_exists(dest)
    for f in file_list:
        f_base = os.path.split(f)[1]
        f_dest = os.path.join(dest, f_base) + ext
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
def copy_raw_resource_files(dest, raw_resource_files):
    dest_dir = os.path.join(dest, "res", "raw")
    _copy_files_to_dir(dest_dir, raw_resource_files, "[RAW RES]")

#
def copy_asset_files(dest, asset_files):
    dest_dir = os.path.join(dest, "assets")
    _copy_files_to_dir(dest_dir, asset_files, "[ASSET]")

#
def copy_png_asset_files(dest, png_asset_files):
    dest_dir = os.path.join(dest, "assets")
    _copy_files_to_dir(dest_dir, png_asset_files, "[ASSET(PNG)]", ".png")

#
#
#
def run_android_project_update(dest, name, dependencies, sdk_root, library,
                               options):

    android_target = options['android-target']
    android = "android"

    if not sdk_root is None:
        android = sdk_root + "/tools/android"

    if library:
        cmd = '%s update lib-project -p %s -t %s' \
            % (android, dest, android_target)
    else:
        cmd = '%s update project -p %s -t %s -n %s --subprojects' \
            % (android, dest, android_target, name)
        for dep in dependencies:
            rel = os.path.relpath(dep, dest)
            verbose(" '%s' -> '%s'" % (dep, rel))
            cmd += ' --library %s' % rel

    verbose("EXEC: %s" % cmd)
    if 0 != subprocess.call(cmd, shell=True):
        return 1;

    # # Add the manifestmerger settings if not already present

    # local_properties = os.path.join(dest, "local.properties")
    # cmd = "if ! grep 'manifestmerger' %s ; then echo manifestmerger.enabled=true >> %s ; fi" % \
    #       (local_properties, local_properties)
    # verbose("EXEC: %s" % cmd)
    # if 0 != subprocess.call(cmd, shell=True):
    #     return 1;

    return 0

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
                        - e.g. 'android-15'
    --name <project-name>
                        - e.g. 'finalfwy'
    --title <app-title>
                        - e.g. 'Final Fwy'
    --package <com.company...myapp>
    --src <src-dir>     - base directory of source files
    --activity <class-name>
    --launcher-activity <class-name>,<label>[,<icon-file>]
                        - (optional) add a basic decl for a launchable activity
                          using the given icon.
    --sdk-version       - minSdkVersion
    --debug             - (optional) set the debuggable flag in the application
    --permissions "<perm1>;<perm2>;.."
                        - (optional) e.g. "com.android.vending.CHECK_LICENSE;
                          android.permission.INTERNET"
    --resource-string name,value
                        - (optional) add a string resource to the APK
    --intent-filters <xml file>
                        - (optional) file with intent filters to add to main
                          activity
    --install-referrer <class-name>
                        - Add an intent filter to the manifest to send
                          INSTALL_REFERRER to the given class
    --no-launcher       - Remove the main LAUNCHER intent so that no launcher
                          icon is created for the app
    --activity-decl <xml file>
                        - (optional) file with an activity in it
    --backup-agent <class>,<appkey>
                        - (optional )Enable backup agent with class and key
    --meta <key>:<value>
                        - (optional) add a meta data key-value pair to the
                          main activity
    --app-meta <key>:<value>
                        - (optional) add a meta tag to the 'application' tag
    --app-tag-name <classname>
                        - (optional) name to use in application tag
    --depends <project-location>
                        - (optional) Can use multiple times
    --icon-dir <icon-dir>
                        - (optional) Use drawable-*/icon.png from <icon-dir>
    --icon-file <icon-file>
                        - (optional) Use specific file as icon
    --banner <banner-dir>
                        - Use drawable-*/banner.png from <banner-dir>
    --key-store <file>  - (optional) Location of keystore
    --key-alias <alias> - (optional) Alias of key in keys store to use
    --xml <file>        - (optional) .xml file to copy to res/xml/
    --value <file>      - (optional) .xml file to copy to res/values/
    --layout <file>     - (optional) .xml file to copy to res/layout/
    --drawable <file>   - (optional) file to copy to res/drawable/
    --raw-resource <file>
                        - file to copy to res/raw/
    --asset <file>      - (optional) asset file to copy to assets
    --png-asset <file>  - (optional) asset file with .png extension
    --landscape <type>  - (optional) type can be: off, on, sensor(default)
    --no-touch          - (optional) don't require touch support
    --android-sdk       - (optional) root of android SDK (if not in path)
    --android-licensing - (optional) code for android licensing
    --proguard <file>   - (optional) enable proguard using given file
    --expansion         - enable manifest entries for expansion files
    --gamepad           - declare game-pad support (with required="false")

    (External services / publishers)
    --acra              - (optional) Acra declarations
    --ouya-icon <icon>  - (optional) icon for Ouya
    --openkit           - (optional) include OpenKit manifest entries
    --amazon-billing    - (optional) include Amazon Billing manifest entries
    --gamecircle        - (optional) include Amazon GameCirlce entries
    --flurry            - (optional) include Flurry permissions
    --nativecrashhandler- (optional) include NativeCrashHandler manifest entries
    --facebook          - (optional) include facebook entries
    --zirconia          - (optional) include Zirconia permissions
    --mobiroo           - (optional) include mobiroo entries to manifest

    (Ad networks)
    --admob             - (optional) include AdMob activity decl
    --mmedia            - (optional) include MillennialMedia manifest entries
    --tapit             - (optional) include MillennialMedia manifest entries
    --mediba            - (optional) include Medbia manifest entries
    --chartboost        - (optional) include ChartBoost manifest entries
    --tapfortap         - (optional) include TapForTap manifest entries
    --heyzap            - (optional) include HeyZap manifest entries
    --appayable         - (optional) include Appayable manifest entries
    --adlooper          - (optional) include AdLooper manifest entries
    --playhaven         - (optional) include playhaven manifest entries
    --greystripe        - (optional) include greystripe manifest entries
    --mdotm             - (optional) include mdotm manifest entries
  Example:

    make_android_project --dest java --version 3.2.5 --target 'android-15' --name 'myproj' --title 'MyProject' --package com.company.project.app --sdk-version 8 --activity MyProjectActivity

"""

def main():

    args = sys.argv
    args.pop(0)

    library = False
    dest = None
    android_sdk_root = None
    version = None
    name = None
    title = None
    package = None
    application_name = None
    activity = None
    sdk_version = "8"
    icon_dir = None
    icon_file = None
    keystore = None
    keyalias = None
    src = []
    extras = []
    permissions = \
        "android.permission.WAKE_LOCK" \
        # ";android.permission.WRITE_SETTINGS"

    intent_filters = None
    meta = {}
    app_meta = {}
    depends = []
    resource_strings = {}
    xml_files = []
    value_files = []
    layout_files = []
    drawable_files = []
    raw_resource_files = []
    asset_files = []
    png_asset_files = []
    options = {
        'android-target': "android-15",
        'landscape': 'sensorLandscape',
        'require-touch': True,
        'activity_files': [],
        'backup_agent': None,
        'nolauncher': False,
        'launcher_activities': [],
        'proguard': None,
        'install-referrer': None,
        'activity_extra_code': "",
        'ouya_icon': None,
        'debug': False,
        'gamepad': False,
        'banner': None,
        }

    def add_meta(kv, meta_map = meta):
        colon_idx = kv.find(':')
        if -1 == colon_idx:
            print "Badly formed meta data: %s" % kv
            usage()
            exit(1)
        k = kv[:colon_idx]
        v = kv[colon_idx+1:]
        print "Saw meta data: KEY: %s, VALUE: %s" % (k, v)
        meta_map[k] = v

    def add_app_meta(kv):
        add_meta(kv, app_meta)

    def add_launcher_activity(ai):
        parts = ai.split(',')
        if 2 > len(parts):
            print "Badly formated launcher activity: %s" % ai
            usage()
            exit(1)

        a = parts[0]
        l = parts[1]
        i_base = None

        if 3 <= len(parts):
            i = parts[2]
            drawable_files.append(i)
            i_base = os.path.splitext(os.path.split(i)[1])[0]

        options['launcher_activities'].append((a,l,i_base))

    def add_activity_code(ac):
        options['activity_extra_code'] += ac

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
            options['android-target'] = args.pop(0)
        elif "--name" == arg:
            name = args.pop(0)
        elif "--title" == arg:
            title = args.pop(0)
        elif "--package" == arg:
            package = args.pop(0)
        elif "--app-tag-name" == arg:
            application_name = args.pop(0)
            if -1 == application_name.find("."):
                application_name = "." + application_name
        elif "--activity" == arg:
            activity = args.pop(0)
        elif "--launcher-activity" == arg:
            add_launcher_activity(args.pop(0))
        elif "--sdk-version" == arg:
            sdk_version = args.pop(0)
        elif "--debug" == arg:
            options['debug'] = True
        elif "--permissions" == arg:
            permissions += ";" + args.pop(0)
        elif "--resource-string" == arg:
            res_kv = args.pop(0).split(",")
            resource_strings[res_kv[0]] = res_kv[1]
        elif "--intent-filters" == arg:
            intent_filters = args.pop(0)
        elif "--install-referrer" == arg:
            options['install-referrer'] = args.pop(0)
        elif "--no-launcher" == arg:
            options['nolauncher'] = True
        elif "--activity-decl" == arg:
            options['activity_files'].append(args.pop(0))
        elif "--backup-agent" == arg:
            options['backup_agent'] = args.pop(0)
        elif "--meta" == arg:
            add_meta(args.pop(0))
        elif "--app-meta" == arg:
            add_app_meta(args.pop(0))
        elif "--depends" == arg:
            depends.append(args.pop(0))
        elif "--icon-dir" == arg:
            icon_dir = args.pop(0)
            icon_file = None
        elif "--icon-file" == arg:
            icon_dir = None
            icon_file = args.pop(0)
        elif "--banner" == arg:
            options['banner'] = args.pop(0)
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
        elif "--raw-resource" == arg:
            raw_resource_files.append(args.pop(0))
        elif "--asset" == arg:
            asset_files.append(args.pop(0))
        elif "--png-asset" == arg:
            png_asset_files.append(args.pop(0))
        elif "--no-landscape" == arg:
            options['landscape'] = None
        elif "--landscape" == arg:
            options['landscape'] = {
                'off': None,
                'on': 'landscape',
                'sensor': 'sensorLandscape'
                }[args.pop(0)]
        elif "--no-touch" == arg:
            options['require-touch'] = False
        elif "--src" == arg:
            src.append(args.pop(0))
        elif "--library" == arg:
            library = True
        elif "--android-licensing" == arg:
            extras.append("androidlicense")
        elif "--proguard" == arg:
            options['proguard'] = args.pop(0)
        elif "--expansion" == arg:
            extras.append('expansion')
        elif "--gamepad" == arg:
            options['gamepad'] = True
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
        elif "--adlooper" == arg:
            extras.append('adlooper')
        elif "--playhaven" == arg:
            extras.append('playhaven')
        elif "--greystripe" == arg:
            extras.append('greystripe')
        elif "--mdotm" == arg:
            extras.append('mdotm')
        elif "--zirconia" == arg:
            extras.append('zirconia')
        elif "--mobiroo" == arg:
            extras.append('mobiroo')
        elif "--acra" == arg:
            extras.append('acra')
        elif "--ouya-icon" == arg:
            options['ouya_icon'] = args.pop(0)
        elif "--openkit" == arg:
            extras.append('openkit')
            extras.append('facebook')
        elif "--facebook" == arg:
            extras.append('facebook')
        elif "--amazon-billing" == arg:
            extras.append('amazon-billing')
        elif "--gamecircle" == arg:
            extras.append('gamecircle')
        elif "--flurry" == arg:
            extras.append('flurry')
        elif "--nativecrashhandler" == arg:
            extras.append('nativecrashhandler')
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
        '%APPLICATION_NAME%' : application_name,
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

    write_manifest(dest, table, permissions, intent_filters, meta, app_meta,
                   extras, library, resource_strings, options)

    # Write ant.properties (dependencies)

    write_ant_properties(dest, depends, src, library, keystore, keyalias,
                         options)

    # Copy icon file

    if icon_dir:
        copy_drawable_files_with_name(dest, icon_dir, "icon.png")
    elif icon_file:
        copy_icon_single_file(dest, icon_file)

    if options['ouya_icon']:
        if "ouya_icon.png" != os.path.split(options['ouya_icon'])[1]:
            raise Exception("Ouya icon must be named ouya_icon.png")
        _copy_files_to_dir(os.path.join(dest, "res", "drawable-xhdpi"),
                           [ options['ouya_icon'] ])

    # Copy banner file(s)

    if options['banner']:
        copy_drawable_files_with_name(dest, options['banner'], "banner.png")

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

    # Copy raw resource files

    if 0 != len(raw_resource_files):
        copy_raw_resource_files(dest, raw_resource_files)

    # Copy asset files

    if 0 != len(asset_files):
        copy_asset_files(dest, asset_files)
    if 0 != len(png_asset_files):
        copy_png_asset_files(dest, png_asset_files)

    # Run 'android update project -p ... --target android-15 -n <name>
    # --library ...'

    global wrote
    if wrote or not os.path.exists(os.path.join(dest, "build.xml")):
        fullname = "%s-%s" % (name, version)
        if not 0 == run_android_project_update(dest, fullname, depends,
                                               android_sdk_root, library,
                                               options):
            return 1
    else:
        print "No project files changed, not running android project update"

    return 0

############################################################

if __name__ == "__main__":
    exit(main())
