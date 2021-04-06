#!/bin/bash
for i in {1..591}
do
   #echo "Executing issue $i"
   grep  "\$\$81\.${i}\$\$.*\$\$81\.${i}\$\$.*" test 
done
