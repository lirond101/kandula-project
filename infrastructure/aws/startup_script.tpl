# #!/bin/bash
# apt update
# apt install nginx awscli -y
# # Welcome page changes-
# sed -i "s/nginx/Grandpa's Whiskey $(hostname)/g" /var/www/html/index.nginx-debian.html
# sed -i '15,23d' /var/www/html/index.nginx-debian.html
# Change Nginx configuration to get real user’s IP address in Nginx log files-
# echo "set_real_ip_from  ${vpc_cidr_block};" >> /etc/nginx/conf.d/default.conf; echo "real_ip_header    X-Forwarded-For;" >> /etc/nginx/conf.d/default.conf
# service nginx restart
# # Upload web server access logs to S3 every hour-
# # echo "0 * * * * aws s3 cp /var/log/nginx/access.log s3://opsschool-lirondadon-nginx-access-log2" > /var/spool/cron/crontabs/root