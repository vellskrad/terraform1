#!/bin/bash
udo yum update -y
sudo amazon-linux-extras install -y php7.2
sudo yum install -y httpd php-mysqlnd
sudo systemctl start httpd
sudo systemctl enable httpd
mkdir -p /var/www/html
sed -i '/<Directory "\/var\/www\/html">/,/<\/Directory>/ s/AllowOverride None/AllowOverride all/' /etc/httpd/conf/httpd.conf
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport ${aws_efs_file_system.EFS1.dns_name}:/ /var/www/html
