#!/bin/bash
grep -o ".*" auth.log | awk '{print $5}' | sort | uniq -c | sort -nr
