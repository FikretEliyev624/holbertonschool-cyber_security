#!/bin/bash
sudo nmap -sA "$1" -p "$2" --reason --host-timeout 1000ms
