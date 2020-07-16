FROM alpine:3.7

ARG USER_ID
ARG GROUP_ID

RUN apk update && \
    apk add build-base \
    bash \
    gcc \
    g++ \
    make \
    grep \
    gperf \
    flex \
    bison \
    autoconf  \
    automake \
    texinfo \
    xz \
    help2man \
    file \
    gawk \
    libtool \
    ncurses-dev \
    gettext-dev \
    binutils \
    wget \
    help2man \
    sed \
    patch \
    coreutils \
    unzip

RUN mkdir -p /opt/cross/
RUN mkdir -p /home/docker_usr/

ENTRYPOINT bash

RUN if [ ${USER_ID:-0} -ne 0 ] && [ ${GROUP_ID:-0} -ne 0 ]; then\
    groupadd -g ${GROUP_ID} docker_usr &&\
    useradd -l -u ${USER_ID} -g docker_usr docker_usr &&\
    install -d -m 0755 -o docker_usr -g docker_usr /home/docker_usr &&\
    chown --changes --silent --no-dereference --recursive \
          ${USER_ID}:${GROUP_ID} \
        /home/docker_usr \
        /opt/cross \
    ;fi

USER root
COPY ./crosstool-ng /home/docker_usr/crosstool-ng
RUN chown --changes --silent --no-dereference --recursive \
        ${USER_ID}:${GROUP_ID} \
        /home/docker_usr/crosstool-ng 
WORKDIR /home/docker_usr/crosstool-ng
USER docker_usr

RUN ./bootstrap
RUN ./configure --prefix=$PWD/../crosstool-ng-build
RUN make
RUN make install

USER root
COPY ./crosstool-ng-workspace /home/docker_usr/crosstool-ng-workspace
RUN chown --changes --silent --no-dereference --recursive \
        ${USER_ID}:${GROUP_ID} \
        /home/docker_usr/crosstool-ng-workspace 
WORKDIR /home/docker_usr/crosstool-ng-workspace
USER docker_usr

RUN ../crosstool-ng-build/bin/ct-ng build
ENV PATH="/opt/cross/bin:${PATH}"

WORKDIR /home/docker_usr
ENTRYPOINT bash
CMD "--help"
