#!/bin/bash

# MARC-Felder sortieren
cp b425_new.seq b425_new_sorted.seq
sed -i 's/^\(.\{10\}\)FMT/\1001/g' b425_new_sorted.seq
sed -i 's/^\(.\{10\}\)LDR/\1002/g' b425_new_sorted.seq

sort -n -s  -k1 -k2.1,2.4 b425_new_sorted.seq > b425_new_sorted.seq2 

sed -i 's/^\(.\{10\}\)001/\1FMT/g' b425_new_sorted.seq2
sed -i 's/^\(.\{10\}\)002/\1LDR/g' b425_new_sorted.seq2

cp b425_new_sorted.seq2 b425_new_sorted.seq

exit 0
