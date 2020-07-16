FROM alpine:3.7
RUN apk add --no-cache bash
RUN apk add --no-cache gcc
RUN apk add --no-cache g++
RUN apk add --no-cache make
RUN apk add --no-cache grep
RUN apk add --no-cache flex
RUN apk add --no-cache bison
RUN apk add --no-cache autoconf 
RUN apk add --no-cache automake
RUN apk add --no-cache texinfo
RUN apk add --no-cache xz
RUN apk add --no-cache help2man
RUN apk add --no-cache file
RUN apk add --no-cache gawk
RUN apk add --no-cache libtool
RUN apk add --no-cache ncurses-dev
RUN apk add --no-cache gettext-dev
COPY ./crosstool-ng /home/crosstool-ng
WORKDIR /home/crosstool-ng
RUN ./bootstrap
RUN CXXFLAGS=-intl ./configure --prefix=$PWD/../crosstool-ng-build
RUN make
RUN make install
RUN apk add --no-cache binutils
RUN apk add --no-cache wget
COPY ./crosstool-ng-workspace /home/crosstool-ng-workspace
WORKDIR /home/crosstool-ng-workspace
RUN ../crosstool-ng-build/bin/ct-ng build
ENV PATH="/opt/cross/arm-armv6l-linux-gnueabi/bin:${PATH}"
ENTRYPOINT bash
CMD "--help"
