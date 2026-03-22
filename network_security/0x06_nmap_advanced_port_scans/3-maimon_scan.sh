#!/bin/bash
sudo nmap -sM -vv -p http,https,ftp,telnet,ssh "$1"
