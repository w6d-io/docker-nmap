FROM instrumentisto/nmap
ARG VCS_REF
ARG BUILD_DATE
ARG VERSION
ARG USER_EMAIL="jack.crosnier@w6d.io"
ARG USER_NAME="Jack CROSNIER"
LABEL maintainer="${USER_NAME} <${USER_EMAIL}>" \
        org.label-schema.vcs-ref=$VCS_REF \
        org.label-schema.vcs-url="https://github.com/w6d-io/docker-nmap" \
        org.label-schema.build-date=$BUILD_DATE \
        org.label-schema.version=$VERSION

ENV DESIRED_VERSION $DESIRED_VERSION
RUN echo y | apk update
RUN echo y | apk add --no-cache git curl
RUN ls
RUN ls -la
RUN mkdir scripts && cd scripts
RUN git clone https://github.com/vulnersCom/nmap-vulners.git vulnersCom_nmapvulner
RUN git clone https://github.com/scipag/vulscan.git scipag_vulscan
COPY scripts/* /usr/local/bin/

