#!/usr/bin/env bash
#
csv=$(speedtest --format=csv --output-header -v)
echo $csv >> $testfile.csv
