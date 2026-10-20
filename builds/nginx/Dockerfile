FROM --platform=linux/amd64 alpine:3.22 AS builder

RUN apk add --no-cache \
    build-base \
    linux-headers \
    pkgconf \
    perl \
    curl \
    tar \
    xz \
    binutils \
    file \
    openssl-dev \
    openssl-libs-static \
    pcre2-dev \
    pcre2-static \
    zlib-dev \
    zlib-static \
    libxml2-dev \
    libxml2-static \
    libxslt-dev \
    libxslt-static \
    xz-dev \
    xz-static \
    libpng-dev \
    libpng-static \
    libjpeg-turbo-dev \
    libjpeg-turbo-static \
    libwebp-dev \
    libwebp-static \
    freetype-dev \
    freetype-static \
    brotli-dev \
    brotli-static \
    bzip2-dev \
    bzip2-static \
    libmaxminddb-dev \
    libmaxminddb-static

WORKDIR /build

ARG NGINX_VERSION=1.30.6
ARG NJS_VERSION=1.0.2
ARG NGX_BROTLI_COMMIT=a71f9312c2deb28875acc7bacfdd5695a111aa53
ARG HEADERS_MORE_VERSION=0.40
ARG GEOIP2_VERSION=3.4
ARG LIBGD_VERSION=2.3.3

RUN fetch() { curl -fsSL --retry 5 --retry-all-errors -o "$2" "$1"; } \
    && fetch https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz nginx.tar.gz \
    && fetch https://github.com/nginx/njs/archive/refs/tags/${NJS_VERSION}.tar.gz njs.tar.gz \
    && fetch https://github.com/google/ngx_brotli/archive/${NGX_BROTLI_COMMIT}.tar.gz ngx_brotli.tar.gz \
    && fetch https://github.com/openresty/headers-more-nginx-module/archive/refs/tags/v${HEADERS_MORE_VERSION}.tar.gz headers-more.tar.gz \
    && fetch https://github.com/leev/ngx_http_geoip2_module/archive/refs/tags/${GEOIP2_VERSION}.tar.gz geoip2.tar.gz \
    && fetch https://github.com/libgd/libgd/releases/download/gd-${LIBGD_VERSION}/libgd-${LIBGD_VERSION}.tar.xz libgd.tar.xz \
    && printf '%s\n' \
    "3cf46f5ed7504d460125866b7bea99fb357f31d887e2e63b35503310e9b8b6c8  nginx.tar.gz" \
    "84a114499fa6878d3ec52b99c1cf2874a91eb0d915408f418a2b1279519f09ae  njs.tar.gz" \
    "1d21be34f3b7b6d05a8142945e59b3a47665edcdfe0f3ee3d3dbef121f90c08c  ngx_brotli.tar.gz" \
    "c14cb5e6c998590c209efbf77bd7637ce2cab02332e4192756a8af5b26ba4284  headers-more.tar.gz" \
    "ad72fc23348d715a330994984531fab9b3606e160483236737f9a4a6957d9452  geoip2.tar.gz" \
    "3fe822ece20796060af63b7c60acb151e5844204d289da0ce08f8fdf131e5a61  libgd.tar.xz" \
    | sha256sum -c - \
    && for f in *.tar.*; do d=${f%%.tar.*}; mkdir $d && tar -xf $f -C $d --strip-components=1; done

# В Alpine нет статической libgd: собираем только с форматами, у которых есть .a.
RUN cd libgd \
    && ./configure --prefix=/usr --enable-static --disable-shared \
    --with-zlib --with-png --with-jpeg --with-webp --with-freetype \
    --without-xpm --without-tiff --without-avif --without-heif \
    --without-fontconfig --without-raqm --without-liq --without-x \
    && make -j$(nproc) install

# ngx_brotli ждёт исходники brotli в git-сабмодуле; подставляем системные заголовки.
RUN mkdir -p ngx_brotli/deps/brotli/c \
    && ln -s /usr/include ngx_brotli/deps/brotli/c/include

# nginx ставит --with-ld-opt перед библиотеками модулей, и статическая линковка
# теряет зависимости libgd/libxml2. Обёртка дописывает их в конец каждой линковки.
RUN printf '%s\n' \
    '#!/bin/sh' \
    'case " $* " in *" -c "*) exec gcc "$@";; esac' \
    'exec gcc "$@" -static $(pkg-config --static --libs gdlib libexslt libxslt libxml-2.0 libmaxminddb libbrotlienc libbrotlidec openssl libpcre2-8 zlib)' \
    > /usr/local/bin/cc-static \
    && chmod +x /usr/local/bin/cc-static

WORKDIR /build/nginx

# Пути и пользователь nginx:nginx — как у пакетов nginx.org. Пользователя создаёт ansible.
RUN ./configure \
    --with-cc=/usr/local/bin/cc-static \
    --prefix=/etc/nginx \
    --user=nginx \
    --group=nginx \
    --sbin-path=/usr/sbin/nginx \
    --modules-path=/usr/lib/nginx/modules \
    --conf-path=/etc/nginx/nginx.conf \
    --error-log-path=/var/log/nginx/error.log \
    --http-log-path=/var/log/nginx/access.log \
    --pid-path=/run/nginx.pid \
    --lock-path=/run/nginx.lock \
    --http-client-body-temp-path=/var/cache/nginx/client_temp \
    --http-proxy-temp-path=/var/cache/nginx/proxy_temp \
    --http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
    --http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
    --http-scgi-temp-path=/var/cache/nginx/scgi_temp \
    --with-compat \
    --with-threads \
    --with-file-aio \
    --with-pcre-jit \
    --with-http_ssl_module \
    --with-http_v2_module \
    --with-http_v3_module \
    --with-http_realip_module \
    --with-http_addition_module \
    --with-http_xslt_module \
    --with-http_image_filter_module \
    --with-http_sub_module \
    --with-http_dav_module \
    --with-http_flv_module \
    --with-http_mp4_module \
    --with-http_gunzip_module \
    --with-http_gzip_static_module \
    --with-http_auth_request_module \
    --with-http_random_index_module \
    --with-http_secure_link_module \
    --with-http_degradation_module \
    --with-http_slice_module \
    --with-http_stub_status_module \
    --with-mail \
    --with-mail_ssl_module \
    --with-stream \
    --with-stream_ssl_module \
    --with-stream_realip_module \
    --with-stream_ssl_preread_module \
    --add-module=../njs/nginx \
    --add-module=../ngx_brotli \
    --add-module=../headers-more \
    --add-module=../geoip2 \
    || { tail -n 40 objs/autoconf.err; exit 1; }

RUN make -j$(nproc) \
    && strip objs/nginx \
    && file objs/nginx \
    && ! readelf -l objs/nginx | grep -q INTERP \
    && ! readelf -d objs/nginx | grep -q NEEDED \
    && objs/nginx -V \
    && mkdir -p /output \
    && cp objs/nginx /output/nginx

# Стадия выгрузки: docker compose копирует бинарник в папку рецепта.
FROM --platform=linux/amd64 alpine:3.22 AS export
COPY --from=builder /output/nginx /nginx
CMD ["cp", "/nginx", "/out/nginx"]
