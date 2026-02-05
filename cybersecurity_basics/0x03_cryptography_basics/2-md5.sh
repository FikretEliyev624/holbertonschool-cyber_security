#!/bin/bash
echo -n "$1" | md5sum | tr -d "-" > 2_hash.txt 
