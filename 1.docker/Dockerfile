# syntax=docker/dockerfile:1

FROM alpine:3.16 AS build_stage
ARG nginx_source_url=https://nginx.org/download/nginx-1.23.0.tar.gz
ENV nginx_source_url=$nginx_source_url
WORKDIR /tmp/nginx_build
RUN wget "$nginx_source_url" -O nginx.tar.gz \
    && \
    apk add gcc               \
            libc-dev          \
            make              \
            openssl-dev       \
            pcre2-dev         \
            zlib-dev          \
            linux-headers     \
            libxslt-dev       \
            gd-dev            \
            geoip-dev         \
            perl-dev          \
            libedit-dev       \
            bash              \
            alpine-sdk        \
            findutils          \
        --no-cache            \
        --virtual .build-deps \
    && \
    mkdir nginx \
    && \
    tar -xf nginx.tar.gz     \
        -C nginx             \
        --strip-components=1 \
    && \
    cd nginx \
    && \
    ./configure --prefix=/etc/nginx                        \
               --sbin-path=/usr/local/bin/nginx          \
               --conf-path=/etc/nginx/nginx.conf         \
               --http-log-path=/var/log/nginx/access.log \
               --error-log-path=/var/log/nginx/error.log \
               --lock-path=/var/lock/nginx.lock          \
               --pid-path=/var/run/nginx.pid             \
               --modules-path=/etc/nginx/modules         \
               --with-http_ssl_module                    \
    && \
    make \
    && \
    make install \
    && \
    nginx -V

FROM alpine:3.16 AS run_stage
COPY ./entrypoint.sh /run/
RUN addgroup -S nginx \
    && \
    adduser -S -D -s /sbin/nologin -h /var/www -G nginx nginx \
    && \
    mkdir -p /etc/nginx/conf.d      \
             /etc/nginx/snippets    \
             /var/log/nginx         \
             /var/cache/nginx       \
             /etc/ssl/certs/nginx   \
             /etc/ssl/private/nginx \
    && \
    touch /var/run/nginx.pid \
    && \
    chown -R nginx:nginx /var/www \
    && \
    chown -R nginx:nginx /etc/nginx \
    && \
    chown -R nginx:nginx /var/log/nginx \
    && \
    chown -R nginx:nginx /var/cache/nginx \
    && \
    chown -R nginx:nginx /etc/ssl/certs/nginx \
    && \
    chown nginx:nginx /etc/ssl/private/nginx \
    && \
    chown nginx:nginx /var/run/nginx.pid \
    && \
    chmod +x /run/entrypoint.sh
COPY ./nginx.conf ./mime.types /etc/nginx/
COPY ./self-signed.conf ./ssl-params.conf /etc/nginx/snippets/
COPY --from=build_stage /usr/local/bin/nginx /usr/local/bin/
COPY --from=build_stage /usr/lib/libpcre2* /usr/lib/
COPY --from=build_stage /usr/bin/openssl /usr/bin/
COPY --from=build_stage /etc/nginx/html/index.html /var/www/html/

EXPOSE 80 443
USER nginx
CMD ["/run/entrypoint.sh"]
