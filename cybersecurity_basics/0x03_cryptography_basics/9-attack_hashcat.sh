#!/bin/bash
hashcat -m 0 -a 0 "$1" "wordlist.txt"
