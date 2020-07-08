#!/usr/bin/env bash
#
#requires speetest
#availiable from 
csv=$(speedtest --format=csv --output-header -v)
echo $csv >> $testfile.csv
