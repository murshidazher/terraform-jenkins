#!/bin/bash
yum install httpd -y

systemctl start httpd
systemctl enable httpd

echo "<h1> Java Home App</h1>" >/var/www/html/index.html
