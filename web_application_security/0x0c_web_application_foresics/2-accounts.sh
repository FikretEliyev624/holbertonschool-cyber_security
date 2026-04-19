#!/bin/bash
tail -n 1000 auth.log | grep "Accepted password" | awk '{print $9}' | grep "root" | uniq
