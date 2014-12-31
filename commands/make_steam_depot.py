#!/usr/bin/env python2.7

import os
import sys
import subprocess

def _ensure_executable(f):
    if not os.path.exists(f):
        raise Exception("tool does not exist: %s" % f)
    if "darwin" == sys.platform or sys.platform.startswith("linux"):
        s = os.stat(f)
        if 0 == (s.st_mode & stat.S_IXUSR):
            print "ensure_executable: %s" % f
            os.chmod(f, s.st_mode | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)

def _steam_cmd(steam_sdk_path):
    join = os.path.join
    normpath = os.path.normpath
    p = sys.platform
    cb_root = join(steam_sdk_path, 'tools', 'ContentBuilder')
    if 'darwin' == p:
        builder_osx_root = join(cb_root, 'builder_osx')
        cmd_bin = join(builder_osx_root, 'osx32', 'steamcmd')
        ensure_executable(cmd_bin)
        cmd= join(builder_osx_root, 'steamcmd.sh')
        ensure_executable(cmd)
        return cmd

    elif p.startswith('linux'):
        return join(steam_sdk_path, 'tools', 'ContentBuilder', 'builder_linux',
                    'steamcmd.sh')
    elif 'win32' == p:
        return normpath(join(steam_sdk_path, 'tools', 'ContentBuilder',
                             'builder', 'steamcmd.exe'))
    return None

def _steam_contentprep(steam_sdk_path):
    join = os.path.join
    exists = os.path.exists

    tools_root = join(steam_sdk_path, 'tools')
    prep_path = join(tools_root, 'ContentPrep.app', 'Contents', 'MacOS',
                     'contentprep.py')
    if not exists(prep_path):
        print "Expanding ContentPrep tool ..."
        if 0 != subprocess.call("unzip ContentPrep.zip",
                                cwd=tools_root, shell=True):
            raise Exception("failed to unzip ContentPrep tool")

    ensure_executable(prep_path)
    return prep_path

################################################################################
# Public Functions
################################################################################

def steam_build_depot(app_id, depot_id, build_path, source_base,
                      description, exclusions,
                      steam_sdk_path, steam_credentials,
                      install_script=None, skip_build=False):
    """
    Creates and runs the app and depot build scripts.

    app_id:
    depot_id:
    build_path: temp path to use for scripts etc
    source_base: where to get content from
    description:
    exclusions: [ "*.pdb", .... ]
    steam_sdk_path:
    steam_credentials: ["<username>", "<password>"]

    Returns the exit code from the build tool.
    """

    assert isinstance(app_id, str)
    assert isinstance(depot_id, str)
    assert isinstance(build_path, str)
    assert isinstance(source_base, str)
    assert isinstance(description, str)
    assert isinstance(exclusions, list)
    assert isinstance(steam_sdk_path, str)
    assert isinstance(steam_credentials, (list, tuple))
    assert isinstance(install_script, (str, None))
    assert isinstance(skip_build, bool)

    join = os.path.join
    abspath = os.path.abspath
    relpath = os.path.relpath
    exists = os.path.exists

    if not os.path.exists(build_path):
        os.makedirs(build_path)
    app_config_file = join(build_path, "app_config_%s.vdf" % app_id)
    depot_config_file = join(build_path, "depot_config_%s.vdf" % depot_id)

    with open(depot_config_file, "wb") as f:
        f.write("""
"DepotBuildConfig"
{
    "DepotID" "%s"
    "ContentRoot" "%s"
    "FileMapping"
    {
        "LocalPath" "*"
        "DepotPath" "."
        "recursive" "1"
    }""" % (depot_id, abspath(source_base)))
        for ex in exclusions:
            f.write('\n    "FileExclusion" "%s"' % ex)
        if install_script:
            if not exists(join(source_base, install_script)):
                raise Exception("no install script '%s'" % \
                                join(source_base, install_script))
            f.write('\n    "InstallScript" "%s"' % install_script)
        f.write("\n}")

    with open(app_config_file, "wb") as f:
        f.write("""
"appbuild"
{
    "appid" "%s"
    "desc" "%s"
    "buildoutput" "%s"
    "contentroot" "%s"
    "depotsskipped" "1"
    "depots"
    {
        "%s" "%s"
    }
}
""" % (app_id, description, \
       build_path, abspath(source_base), \
       depot_id, relpath(depot_config_file, build_path)))

    print ""
    print " Steam build files:"
    print "  %s" % app_config_file
    print "  %s" % depot_config_file
    print ""

    steam_cmd = _steam_cmd(steam_sdk_path)

    cmd = "%s +login %s %s +run_app_build %s +quit" % \
          (steam_cmd, steam_credentials[0], steam_credentials[1],
           app_config_file)
    print ""
    print " Steam build command:"
    print "  %s" % cmd
    print ""

    if skip_build:
        return 0
    return subprocess.call(cmd, shell=True)



def _help():
    def p(msg):
        print(msg)

    p("Usage:")
    p("")
    p("Required:")
    p("  --app-id <app-id>             Steam App ID")
    p("  --depot-id <depot-id>         Steam Depot ID")
    p("  --build-path <build-path>     Temporary path for scripts / build data")
    p("  --source-base <path>          Root directory to bundle files from")
    p("  --steam-path <path>           Steam 'sdk' directory")
    p("  --steam-credentials <un:pw>   Steam account")
    p("")
    p(" Optional:")
    p("  --exclude \"<pattern>\"         Pattern embedded as-is in scripts")
    p("  --description <description>   Decription of this build")
    p("  --install-script <scriptfile> Steam install script")
    p("  --skip-build                  Just write the scripts.  Don't build")

def run(args):

    app_id = None
    depot_id = None
    build_path = None
    source_base = None
    steam_path = None
    steam_credentials = None

    description = ""
    exclusions = []
    install_script=None
    skip_build=False

    args.pop(0)
    while 0 != len(args):
        a = args.pop(0)
        if "--app-id" == a:
            app_id = args.pop(0)
        elif "--depot-id" == a:
            depot_id = args.pop(0)
        elif "--build-path" == a:
            build_path = args.pop(0)
        elif "--source-base" == a:
            source_base = args.pop(0)
        elif "--description" == a:
            description = args.pop(0)
        elif "--exclude" == a:
            exclusions.append(args.pop(0))
        elif "--steam-path" == a:
            steam_path = args.pop(0)
        elif "--steam-credentials" == a:
            steam_credentials = args.pop(0)
        elif "--install-script" == a:
            install_script = args.pop(0)
        elif "--skip-build" == a:
            skip_build = args.pop(0)
        else:
            _help()
            return 1

    if app_id is None:
        print "app_id not specified"
        _help()
        return 1
    if depot_id is None:
        print "depot_id not specified"
        _help()
        return 1
    if build_path is None:
        print "build_path not specified"
        _help()
        return 1
    if source_base is None:
        print "source_base not specified"
        _help()
        return 1
    if steam_path is None:
        print "steam_path not specified"
        _help()
        return 1
    if steam_credentials is None:
        print "steam_credentials not specified"
        _help()
        return 1

    return steam_build_depot(app_id,
                             depot_id,
                             build_path,
                             source_base,
                             description,
                             exclusions,
                             steam_sdk_path,
                             steam_credentials.split(":"),
                             install_script,
                             skip_build)

if "__main__" == __name__:
    # print "HERE"
    # exit(0)
    exit(run(sys.argv))
