FROM alpine:3.7
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
COPY ./crosstool-ng /home/crosstool-ng
WORKDIR /home/crosstool-ng
RUN ./bootstrap
RUN ./configure --prefix=$PWD/../crosstool-ng-build
RUN make
RUN make install
COPY ./crosstool-ng-workspace /home/crosstool-ng-workspace
WORKDIR /home/crosstool-ng-workspace
RUN ../crosstool-ng-build/bin/ct-ng build
RUN mv /home/crosstool-ng-workspace/opt /
ENV PATH="/opt/cross/bin:${PATH}"
WORKDIR /home/
ENTRYPOINT bash
#CMD "--help"
