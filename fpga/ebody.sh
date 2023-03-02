#!/bin/bash
rstr="Dear All,\n\n\tBelow is the summary:"
while read line; do
    rstr="${rstr}\n\t"
    rstr="${rstr}${line}"
done < $1
rplink="https://ci.cixcomputing.com/job/$2/AP_5fBSP-Test-Report/"
rstr="${rstr}\n\t"
rstr="${rstr}The full report link is: ${rplink}"
rstr="${rstr}\n\n"
rstr="${rstr}SW-Test-Robot"

echo -e $rstr
    

