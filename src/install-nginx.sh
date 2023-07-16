#! /bin/bash
sudo apt-get update
sudo apt install nginx -y
sudo awk -i inplace 'NR==53{print "\tlocation /myapp {proxy_pass http://10.0.6.4:1530/;}"}1' /etc/nginx/sites-available/default
sudo systemctl restart nginx
sudo sh -c "echo '<html><body><h1>Bienvenido al servidor `uname -n`</h1></body></html>' > /var/www/html/index.nginx-debian.html"