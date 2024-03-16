#!/bin/bash

sudo apt-get update -y
sudo apt-get install nginx -y
cat << EOF > /etc/nginx/nginx.conf
user www-data;
worker_processes auto;
pid /run/nginx.pid;
error_log /var/log/nginx/error.log;
load_module /usr/lib/nginx/modules/ngx_stream_module.so;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    access_log /var/log/nginx/access.log;
    sendfile on;

    tcp_nopush on;
    tcp_nodelay on;

    ssl_protocols TLSv1 TLSv1.1 TLSv1.2; # Dropping SSLv3, ref: POODLE
    ssl_prefer_server_ciphers on;

    keepalive_timeout 65;
    types_hash_max_size 2048;

    real_ip_header X-Forwarded-For;
    add_header 'Access-Control-Allow-Origin' '*';

    log_format custom '\$remote_addr - \$remote_user [\$time_local] '
      '"\$request_method \$obfuscated_request_uri \$server_protocol" \$status $body_bytes_sent '
      '"\$http_referer" "\$http_user_agent"';

    map \$request_uri \$obfuscated_request_uri {
      ~(.+\?)?(.*&)?(api_key=)[^&]*(&.*|$) \$1\$2\$3********\$4;
      default \$request_uri;
    }

    server {
        listen 3834; #listen for metrics
        access_log /var/log/nginx/access.log custom;
        error_log /dev/null;

        location /api/v1/validate {
            proxy_pass https://api.datadoghq.com:443/api/v1/validate;
        }
        location /support/flare/ {
            proxy_pass https://flare.datadoghq.com:443/support/flare/;
        }
        location / {
            proxy_pass https://haproxy-app.agent.datadoghq.com:443/;
        }
    }
}
EOF
sudo systemctl restart nginx.service
