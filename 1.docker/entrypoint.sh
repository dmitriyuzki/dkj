#!/bin/sh
if [ ! -f /etc/ssl/certs/nginx/selfsigned.crt ] || [ ! -f /etc/ssl/private/nginx/selfsigned.key ]; then
    openssl req -x509 \
                -nodes \
                -days 28 \
                -newkey rsa:2048  \
                -keyout /etc/ssl/private/nginx/selfsigned.key \
                -out /etc/ssl/certs/nginx/selfsigned.crt \
                -subj "/C=US/ST=New York/L=New York City/O=Some Org/CN=*"                
    openssl dhparam -out /etc/nginx/dhparam.pem 1024
fi

/usr/local/bin/nginx -g 'daemon off;'
