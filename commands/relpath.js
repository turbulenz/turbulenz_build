// Copyright (c) 2015 Turbulenz Limited

var print = function(m)
{
    WScript.Echo(m);
};

var sanitize = function(p)
{
    // print("p: " + p);
    var res = p.replace(/\\/g, "/").toLowerCase();
    // print("res: " + res);
    return res;
};

var relpath = function (path)
{
    var colonIdx = path.indexOf(":");
    if (-1 === colonIdx)
    {
        return path;
    }

    var objShell = WScript.CreateObject("WScript.Shell");
    var cwd = sanitize(objShell.CurrentDirectory);

    if (path.substr(0,1) !== cwd.substr(0,1))
    {
        return path;
    }

    var pathSplit = path.split("/");
    var cwdSplit = cwd.split("/");

    var same = 0;
    while (pathSplit[same] === cwdSplit[same])
    {
        same += 1;
    }

    var relpath = "";
    var dotDots = cwdSplit.length - same;
    while (dotDots)
    {
        relpath += "../";
        dotDots -= 1;
    }

    while (same < pathSplit.length)
    {
        relpath += pathSplit[same] + "/";
        same += 1;
    }

    // print("relpath: " + relpath);
    // print("relpath.substr(-1): " + relpath.substr(relpath.length-1));

    if (relpath.substr(relpath.length-1) === "/")
    {
        relpath = relpath.substr(0, relpath.length-1);
    }

    // print(relpath);
    return relpath;
};

var path = sanitize(WScript.Arguments(0));
print(relpath(path));
