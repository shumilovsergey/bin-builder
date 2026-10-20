FROM --platform=linux/amd64 alpine:3.22 AS builder

RUN apk add --no-cache \
    build-base \
    linux-headers \
    curl \
    tar \
    binutils \
    file

WORKDIR /build

ARG BIN_VERSION=0.0.0

RUN curl -fsSL --retry 5 --retry-all-errors -o src.tar.gz \
    https://example.org/bin-name-${BIN_VERSION}.tar.gz \
    && echo "<sha256>  src.tar.gz" | sha256sum -c - \
    && mkdir src && tar -xzf src.tar.gz -C src --strip-components=1

WORKDIR /build/src

RUN ./configure \
    && make -j$(nproc) LDFLAGS="-static" \
    && strip bin-name \
    && file bin-name \
    && ! readelf -l bin-name | grep -q INTERP \
    && ! readelf -d bin-name | grep -q NEEDED \
    && ./bin-name --version \
    && mkdir -p /output \
    && cp bin-name /output/bin-name

FROM --platform=linux/amd64 alpine:3.22 AS export
COPY --from=builder /output/bin-name /bin-name
CMD ["cp", "/bin-name", "/out/bin-name"]
