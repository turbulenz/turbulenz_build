#!/usr/bin/env python2.7

import os
import sys

join = os.path.join
split = os.path.split
splitext = os.path.splitext
relpath = os.path.relpath

##################################################################
# UTILS
##################################################################

def _verbose(msg):
    print "%s" % msg
def _silent(msg):
    pass
verbose = _verbose #_silent

def mkdir_if_not_exists(path):
    if not os.path.exists(path):
        os.mkdir(path)

def replace_tags(in_string, table):
    for tag in table:
        in_string = in_string.replace(tag, "%s" % table[tag])
    return in_string

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

def read_file(src):
    with open(src, 'rb') as in_f:
        return in_f.read()

def copy_file_if_different(src, target):
    data = read_file(src)
    write_file_if_different(target, data)

##################################################################

#
def plist_set_version(plist_data, version_str):
    """

	<key>CFBundleShortVersionString</key>
	<string>0.1</string>

	<key>CFBundleVersion</key>
	<string>0.1</string>

    """

    plist_lines = plist_data.split("\n")
    plist_num_lines = len(plist_lines)

    out_lines = []
    line_idx = 0

    while line_idx < plist_num_lines:
        l = plist_lines[line_idx]
        line_idx += 1

        out_lines.append(l)

        if -1 != l.find("CFBundleShortVersionString") or \
                -1 != l.find("CFBundleVersion"):
            out_lines.append("	<string>%s</string>" % version_str)
            line_idx += 1

    return "\n".join(out_lines)


#
def plist_set_bundle_id(plist_data, bundle_id):
    """

	<key>CFBundleIdentifier</key>
	<string>com.turbulenz.turbulenzdev</string>

    """

    plist_lines = plist_data.split("\n")
    plist_num_lines = len(plist_lines)

    out_lines = []
    line_idx = 0

    while line_idx < plist_num_lines:
        l = plist_lines[line_idx]
        line_idx += 1

        out_lines.append(l)

        if -1 != l.find("CFBundleIdentifier"):
            out_lines.append("	<string>%s</string>" % bundle_id)
            line_idx += 1

    return "\n".join(out_lines)

#
def plist_set_bundle_icon(plist_data, icon_ref_name):
    """

	<key>CFBundleIconFile</key>
	<string>icons</string>

    """

    plist_lines = plist_data.split("\n")
    plist_num_lines = len(plist_lines)

    out_lines = []
    line_idx = 0

    while line_idx < plist_num_lines:
        l = plist_lines[line_idx]
        line_idx += 1

        out_lines.append(l)

        if -1 != l.find("CFBundleIconFile"):
            out_lines.append("	<string>%s</string>" % icon_ref_name)
            line_idx += 1

    return "\n".join(out_lines)

#
def plist_strip_url_handling(plist_data):

    plist_lines = plist_data.split("\n")
    plist_num_lines = len(plist_lines)

    out_lines = []
    line_idx = 0

    # Look for the start of the URLTypes section

    while line_idx < plist_num_lines:
        l = plist_lines[line_idx]
        line_idx = line_idx + 1

        if -1 != l.find("CFBundleURLTypes"):
            break

        out_lines.append(l)

    # Ignore all lines until we've removed all arrays defined

    array_depth = 0
    while line_idx < plist_num_lines:
        l = plist_lines[line_idx]
        line_idx = line_idx + 1

        if -1 != l.find("<array>"):
            array_depth += 1
        elif -1 != l.find("</array>"):
            array_depth -= 1
            if 0 == array_depth:
                break

    # Include any further data

    while line_idx < plist_num_lines:
        l = plist_lines[line_idx]
        line_idx = line_idx + 1

        out_lines.append(l)

    return "\n".join(out_lines)

#
def copy_resources(config):

    dest_dir = config['destdir']
    dest_resources_dir = join(dest_dir, config['appname'])
    dest_project_name = config['appname']
    mkdir_if_not_exists(dest_resources_dir)

    src_project_dir = config['srcprojectdir']
    src_project_name = os.path.basename(src_project_dir)
    verbose("srcproj_name: %s" % src_project_name)

    icons_base = config['icons-base']

    # Info.plist file

    dest_info_plist = join(dest_resources_dir,
                           "%s-Info.plist" % dest_project_name)
    src_info_plist = join(src_project_dir,
                          "%s-Info.plist" % src_project_name)

    plist_data = read_file(src_info_plist)
    plist_data = plist_set_version(plist_data, config['version-number'])

    if config['strip-url-handling']:
        plist_data = plist_strip_url_handling(plist_data)

    if config['bundle-id']:
        plist_data = plist_set_bundle_id(plist_data, config['bundle-id'])

    if "macosx" == config['target']:

        if config['icons-base']:

            # # copy the icons into the project

            # project_icons_dir = join(dest_resources_dir, "icons.iconset")
            # mkdir_if_not_exists(project_icons_dir)

            # for i in [ "icon_16x16.png", "icon_16x16@2x.png",
            #            "icon_32x32.png", "icon_32x32@2x.png",
            #            "icon_128x128.png", "icon_128x128@2x.png",
            #            "icon_256x256.png", "icon_256x256@2x.png",
            #            "icon_512x512.png", "icon_512x512@2x.png" ]:
            #     f = join(config['icons-base'], i)
            #     if os.path.exists(f):
            #         print "Copying icon '%s'" % i
            #         copy_file_if_different(f, join(project_icons_dir, i))

            # plist_data = plist_set_bundle_icon(plist_data, 'icons')

            plist_data = plist_set_bundle_icon( \
                plist_data,  \
                splitext(split(config['icons-base'])[1])[0] \
            )

    write_file_if_different(dest_info_plist, plist_data)

    if "ios" == config['target']:

        # Default-*.png

        for def_file in [ 'Default.png',
                          'Default@2x.png',
                          'Default-568h@2x.png' ]:
            copy_file_if_different(join(src_project_dir, def_file),
                                   join(dest_resources_dir, def_file));

        # Icon files

        if config['icons-base']:
            for suffix in [ '57x57.png', '57x57@2x.png',
                            '72x72.png', '72x72@2x.png' ]:
                copy_file_if_different("%s%s" % (icons_base, suffix),
                                       join(dest_resources_dir,
                                            "icon_%s" % suffix))

#
def write_gyp_file(gyp_file_name, config):
    """
    Return True on success
    """

    dest_dir = config['destdir']

    defines = ""
    if config['launch-url']:
        defines += "'LAUNCH_URL=\"%s\"'" % config['launch-url']

    tags = {
        '__APPNAME__': config['appname'],
        '__TZROOT__': relpath(".", dest_dir),
        '__SRCPROJDIR__': relpath(config['srcprojectdir'], dest_dir),
        '__DEFINES__': defines,
        '__ICONBASE__': relpath(config['icons-base'], dest_dir)
    }

    gyp_data = read_file(config['gyp-template'])
    gyp_data = replace_tags(gyp_data, tags)
    write_file_if_different(gyp_file_name, gyp_data)
    return True

############################################################

def usage():

    print """
  Usage:

    make_ios_project --app-name <app-name> --dest-dir <dest-dir> [<options>]

  Options:

    --macosx
        (Optional) Create an OS X project instead of iOS

    --app-name <appname>
        (Required) Name of the application

    --dest-dir <dest-dir>
        (Required) The location into which to generate and copy project files

    --bundle-id <bundle-id>
        (Optional) Bundle ID.  If not specified, use the ID assigned
        automatically by Xcode.

    --version X.Y.Z
        (Optional) A version number to embed in the project

    --icons-base <base>
        (Optional) This scripts expects to find files of the correct sizes:
            <base>57x57.png
            <base>57x57@2x.png
            <base>72x72.png
            <base>72x72@2x.png
        For OS X target:
            <base>/icons_32x32.png

    --launch-url <url>
        (Optional) The url to hard-code into the app

    --template-project <directory>
        (Optional) A directory containing a template project.  It should have:
            Default*.png
            <project-name>-Info.plist
            Settings.bundle
            All the required source code
            ...
        For OS X targets, it should have:
            icons.iconset/....png
            <project-name>-Info.plist
            All the source code
        Best to leave this as the default, unless you need some heavy
        customization.

"""

def make_ios_project():

    config = {
        'target': "ios",
        'destdir': None,
        'appname': None,
        'bundle-id': None,
        'srcprojectdir': 'src/standalone/ios/turbulenz-test',
        'version-number': "0.1.0",
        'icons-base': None,
        'launch-url': None,
        'strip-url-handling': False,

        'gyp-template': None
    }

    args = sys.argv[1:]
    while len(args) > 0:
        a = args.pop(0)

        if a in [ '-h', '--help' ]:
            usage()
            return 0
        elif "--macosx" == a:
            config['target'] = "macosx"
        elif "--app-name" == a:
            config['appname'] = args.pop(0)
        elif "--dest-dir" == a:
            config['destdir'] = args.pop(0)
        elif "--bundle-id" == a:
            config['bundle-id'] = args.pop(0)
        elif "--version" == a:
            config['version-number'] = args.pop(0)
        elif "--icons-base" == a:
            config['icons-base'] = args.pop(0)
        elif "--template-project" == a:
            config['srcprojectdir'] = args.pop(0)
        elif "--launch-url" == a:
            config['launch-url'] = args.pop(0)
        elif "--strip-url-handlers" == a:
            config['strip-url-handling'] = True
        else:
            print "ERROR: unrecognised option: %s" % a
            usage()
            return 1

    if not config['gyp-template']:
        config['gyp-template'] = "build/%s/template.gyp" % config['target']

    # Sanity check args

    if not config['appname']:
        print "ERROR: no --app-name flag given"
        usage()
        return 1
    if not config['destdir']:
        print "ERROR: no --dest-dir flag given"
        usage()
        return 1

    # Create dest dir

    mkdir_if_not_exists(config['destdir'])

    # Copy resources

    copy_resources(config)

    # Create gyp file

    gyp_file_name = join(config['destdir'], config['appname'] + ".gyp")
    if not write_gyp_file(gyp_file_name, config):
        print "ERROR: failed to write gyp file: %s" % gyp_file_name
        return 1

    print " written .gyp file: %s" % gyp_file_name
    print " build with: gyp --depth \"%s\" \"%s\"" % \
        (os.path.split(gyp_file_name)[0], gyp_file_name)
    return 0


if "__main__" == __name__:
    exit(make_ios_project())
