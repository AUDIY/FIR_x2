# dec2hex.awk
# How to use: awk -v width=4 -v out="output.data" -f dec2hex.awk input.txt
BEGIN {
    if (width == "" || width <= 0) {
        print "Error: 'width' must be specified and > 0" > "/dev/stderr"
        exit 1
    }
    if (out == "") {
        print "Error: 'out' must be specified" > "/dev/stderr"
        exit 1
    }

    max_val = 2^(width * 4)
    half = max_val / 2
    fmt = "%0" width "X"
}

{
    dec = int($1)

    # Convert to two'2 complement.
    if (dec < 0) {
        dec = max_val + dec
    }

    if (dec >= max_val || dec < 0) {
        print "Warning: Value out of range at line " NR ": " $1 > "/dev/stderr"
        next
    }

    hex = sprintf(fmt, dec)
    print hex >> out
}
