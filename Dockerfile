# https://hub.docker.com/_/alpine
FROM alpine:3.13.5
ARG VCS_REF
ARG BUILD_DATE
ARG VERSION
ARG USER_EMAIL="jack.crosnier@w6d.io"
ARG USER_NAME="Jack CROSNIER"
LABEL maintainer="${USER_NAME} <${USER_EMAIL}>" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vcs-url="https://github.com/w6d-io/docker-owaspzap" \
        org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.version=$VERSION

ARG nmap_ver=7.91
ARG build_rev=4

LABEL org.opencontainers.image.source="\
    https://github.com/instrumentisto/nmap-docker-image"

# Install dependencies
RUN apk add --update --no-cache \
            ca-certificates \
            busybox-extras \
            libpcap \
            libgcc libstdc++ \
            libressl3.1-libcrypto libressl3.1-libssl \
 && update-ca-certificates \
 && rm -rf /var/cache/apk/*


# Compile and install Nmap from sources
RUN apk add --update --no-cache --virtual .build-deps \
        libpcap-dev libressl-dev lua-dev linux-headers \
        autoconf g++ libtool make \
        curl \

 && curl -fL -o /tmp/nmap.tar.bz2 \
         https://nmap.org/dist/nmap-${nmap_ver}.tar.bz2 \
 && tar -xjf /tmp/nmap.tar.bz2 -C /tmp \
 && cd /tmp/nmap* \
 && ./configure \
        --prefix=/usr \
        --sysconfdir=/etc \
        --mandir=/usr/share/man \
        --infodir=/usr/share/info \
        --without-zenmap \
        --without-nmap-update \
        --with-openssl=/usr/lib \
        --with-liblua=/usr/include \
 && make \
 && make install \

 && apk del .build-deps \
 && rm -rf /var/cache/apk/* \
           /tmp/nmap*

#Copy doesn't respect USER directives so we need to chown and to do that we need to be root
#Copy doesn't respect USER directives so we need to chown and to do that we need to be root
USER root

RUN echo y | apk update
RUN echo y | apk add --no-cache git curl
RUN mkdir -p /scripts && cd /scripts && \
    git clone https://github.com/vulnersCom/nmap-vulners.git vulnersCom_nmapvulner && \
    git clone https://github.com/scipag/vulscan.git scipag_vulscan

ENTRYPOINT ["/usr/bin/nmap"]
