#!/bin/bash
find "$1" -type f -perm -4000 -exec ls -la {} \; 2>/dev/null
