#!/bin/bash
echo -n "$1" | sha256sum  |tr -d "-" > 1_hash.txt
