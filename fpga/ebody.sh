#!/bin/bash
rstr="Dear All,\n\n\tBelow is the summary:"
while read line; do
    rstr="${rstr}\n\n\t"
    rstr="${rstr}${line}"
done < $1
rstr="${rstr}\n\n"
rstr="${rstr}\n\n\t"
rstr="${rstr}SW-Test-Robot"

echo $rstr
    

