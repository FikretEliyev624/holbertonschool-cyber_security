#!/bin/bash
sudo nmap -Pn -sX -p 440-450 --open --reason --packet-trace "$1"
