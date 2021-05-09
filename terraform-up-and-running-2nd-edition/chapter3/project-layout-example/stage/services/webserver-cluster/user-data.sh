#!/bin/bash 

echo "address: ${db_address}, port: ${db_port}" >> index.html
nohup busybox httpd -f -p ${server_port} &