
import os
import sys
import subprocess
import re
import tempfile

VERBOSE=False
def verbose(msg):
    if VERBOSE:
        sys.stderr.write(msg)

def timestamp(filename):
    if not os.path.exists(filename):
        return 0
    s = os.stat(filename)
    return s.st_mtime

def help():
    print " Usage:"
    print "   run_tsc [options] --out <outfile.js> <infiles> ..."
    print ""
    print " Options are as for tsc, including:"
    print ""
    print "   -v                  - Write out internal debugging messages"
    print ""
    print "   -Werror             - If any errors are output to stderr, behave "
    print "                         as if compilation failed (exit non-zero and"
    print "                         remove all output files"
    print ""
    print "   -Wnone              - Suppress all warning output"
    print ""
    print "   --tsc <tsc path>    - Call tsc with the given path"
    print ""
    print "   -filter <pattern>   - Only display warnings matching pattern"
    print ""

def main():

    outfile = None
    error_on_warning = False
    print_warnings = True
    expect_d_ts_file = None
    dump_output_to_stdout = False
    warning_filter = ""
    tsc_path = "tsc"

    # Parse args

    tsc_args = []
    args = sys.argv[1:]
    while len(args):
        a = args.pop(0)
        if "--out" == a:
            outfile = args.pop(0)
        elif "-v" == a:
            global VERBOSE
            VERBOSE = True
        elif "-Werror" == a:
            error_on_warning = True
        elif "-Wnone" == a:
            print_warnings = False
        elif "--declaration" == a:
            expect_d_ts_file = True
            tsc_args.append(a)
        elif "--tsc" == a:
            tsc_path = args.pop(0)
        elif "--filter" == a:
            warning_filter = args.pop(0)
        else:
            tsc_args.append(a)

    if outfile is None:
        print "run_tsc tool requires explicit output file"
        return 3

    # Allow output to stdout

    if outfile == "-":
        verbose("Output to stdout\n")
        dump_output_to_stdout = True
        tmp = tempfile.NamedTemporaryFile(suffix=".js", delete=False)
        outfile = tmp.name
        tmp.close()
        os.unlink(outfile)

        verbose("tmpfile is %s\n" % outfile)

    # Append the outfile args to the tsc_args

    tsc_args.append("--out")
    tsc_args.append(outfile)

    if expect_d_ts_file:
        expect_d_ts_file = os.path.splitext(outfile)[0] + ".d.ts"

    # Check output file timestamp

    outfile_timestamp = timestamp(outfile)
    verbose("orig timestamp: %s\n" % outfile_timestamp)
    if not expect_d_ts_file is None:
        d_ts_timestamp = timestamp(expect_d_ts_file)

    # Run command

    tsc_cmd = "%s %s" % (tsc_path, " ".join(tsc_args))

    verbose("CMD: %s\n" % tsc_cmd)
    p = subprocess.Popen(tsc_cmd, shell=True, stderr=subprocess.PIPE)
    (_, err) = p.communicate()

    # Print (re-format) warnings if asked to

    def output_warnings(err):
        error_re = re.compile("^(.+)\(([0-9]+)\,([0-9]+)\)\: (.+)$")
        stderr = sys.stderr
        total_lines = 0
        for line in err.split("\n"):
            if -1 == line.find(warning_filter):
                continue

            if total_lines > 16:
                break

            # print "ERR LINE: %s" % line
            m = error_re.match(line)
            if not m is None:
                filename = m.group(1)
                lineno = m.group(2)
                charno = m.group(3)
                errmsg = m.group(4)
                stderr.write("%s:%s:%s: warning: %s\n" \
                                 % (filename.rstrip(), lineno, charno, errmsg))
                verbose("ORIG: %s\n" % line)
                total_lines = total_lines + 1
            else:
                stderr.write(line)
                stderr.write("\n")

    if print_warnings:
        output_warnings(err)

    # Dump file?

    if dump_output_to_stdout:
        # TODO: dump output
        pass

    # Get process exit code

    tsc_ret = p.wait()
    verbose("tsc exited with code %d\n" % tsc_ret)

    # Was the file updated?

    outfile_new_ts = timestamp(outfile)
    verbose("new timestamp: %s\n" % outfile_new_ts)
    outfile_updated =  outfile_new_ts > outfile_timestamp
    verbose("output '%s' was updated: %s\n" % (outfile, outfile_updated))

    if not expect_d_ts_file is None:
        d_ts_file_updated = timestamp(expect_d_ts_file) > d_ts_timestamp
        verbose("output '%s' was updated: %s\n" \
                    % (expect_d_ts_file, d_ts_file_updated))

    # Error on warning?  If so, any error forces a non-zero exit
    # value.  If not, we exit 0 as long as the output file was
    # generated.

    if error_on_warning:
        if 0 != len(err):
            tsc_ret = tsc_ret or 1
    else:
        if outfile_updated:
            tsc_ret = 0
        else:
            # Warnings were disabled, presumably for a crude .ts to
            # .js lib build, but no output was generated.  Force
            # stderr to be echoed, even if it was disabled on the
            # command line:
            if not print_warnings:
                output_warnings(err)

    # Always clean up output files if the compiler exited with an
    # error

    if 0 != tsc_ret:
        if os.path.exists(outfile) and outfile_updated:
            verbose("REMOVING: %s\n" % outfile)
            os.remove(outfile)

        if (not expect_d_ts_file is None) and \
                (os.path.exists(expect_d_ts_file) and d_ts_file_updated):
            verbose("REMOVING: %s\n" % expect_d_ts_file)
            os.remove(expect_d_ts_file)

    # Return error code

    return tsc_ret


if "__main__" == __name__:
    exit(main())
