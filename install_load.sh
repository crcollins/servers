#!/usr/bin/env bash

sudo apt-get update
sudo apt-get install -y nginx


cat > /etc/nginx/nginx.conf <<\EOF
user www-data;
worker_processes 4;
pid /var/run/nginx.pid;

events {
    worker_connections 768;
    # multi_accept on;
}

http {
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;

    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    log_format upstreamlog '[$time_local] $remote_addr - $remote_user - $server_name  to: $upstream_addr: $request upstream_response_time $upstream_response_time msec $msec request_time $request_time';
    access_log /var/log/nginx/access.log upstreamlog;
    error_log /var/log/nginx/error.log;

    gzip on;
    gzip_disable "msie6";

    include /etc/nginx/conf.d/*.conf;
    include /etc/nginx/sites-enabled/*;

    upstream myapp1 {
EOF

for i in `seq $1 $2`; do echo "        server 192.168.2.$i;" >> /etc/nginx/nginx.conf; done

cat >> /etc/nginx/nginx.conf <<\EOF
    }

    server {
        listen 80;

        location / {
            proxy_set_header  Host  $host;
            proxy_set_header  X-Real-IP $remote_addr;
            proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass http://myapp1;
        }
    }
}
EOF

sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -s reload
sudo service nginx restart



