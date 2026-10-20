FROM --platform=linux/amd64 alpine:3.22 AS builder

RUN apk add --no-cache \
    build-base \
    linux-headers \
    openssl-dev \
    openssl-libs-static \
    pcre2-dev \
    pcre2-static \
    lua5.4-dev \
    curl \
    tar \
    binutils \
    file

WORKDIR /build

ARG HAPROXY_VERSION=3.2.26

RUN curl -fsSLO --retry 5 --retry-all-errors \
    https://www.haproxy.org/download/3.2/src/haproxy-${HAPROXY_VERSION}.tar.gz \
    && curl -fsSLO --retry 5 --retry-all-errors \
    https://www.haproxy.org/download/3.2/src/haproxy-${HAPROXY_VERSION}.tar.gz.sha256 \
    && sha256sum -c haproxy-${HAPROXY_VERSION}.tar.gz.sha256 \
    && tar -xzf haproxy-${HAPROXY_VERSION}.tar.gz

WORKDIR /build/haproxy-${HAPROXY_VERSION}

# Всё вшиваем статически: OpenSSL, PCRE2 (+JIT), Lua 5.4, QUIC, Prometheus.
RUN make -j$(nproc) \
    TARGET=linux-musl \
    USE_OPENSSL=1 \
    USE_QUIC=1 \
    USE_PCRE2=1 \
    USE_PCRE2_JIT=1 \
    USE_LUA=1 \
    LUA_INC=/usr/include/lua5.4 \
    LUA_LIB=/usr/lib/lua5.4 \
    LUA_LIB_NAME=lua \
    USE_PROMEX=1 \
    LDFLAGS="-static" \
    && strip haproxy \
    && file haproxy \
    && ! readelf -l haproxy | grep -q INTERP \
    && ! readelf -d haproxy | grep -q NEEDED \
    && ./haproxy -vv \
    && mkdir -p /output \
    && cp haproxy /output/haproxy

# Стадия выгрузки: docker compose копирует бинарник в папку рецепта.
FROM --platform=linux/amd64 alpine:3.22 AS export
COPY --from=builder /output/haproxy /haproxy
CMD ["cp", "/haproxy", "/out/haproxy"]
