FROM debian:buster-slim
RUN apt-get update -y
RUN apt-get install -y bash
RUN apt-get install -y gcc
RUN apt-get install -y g++
RUN apt-get install -y make
RUN apt-get install -y grep
RUN apt-get install -y flex
RUN apt-get install -y bison
RUN apt-get install -y autoconf 
RUN apt-get install -y automake
RUN apt-get install -y texinfo
RUN apt-get install -y help2man
RUN apt-get install -y file
RUN apt-get install -y gawk
RUN apt-get install -y libtool
RUN apt-get install -y ncurses-dev
RUN apt-get install -y gettext
RUN apt-get install -y bzip2
RUN apt-get install -y xz-utils
RUN apt-get install -y zip
RUN apt-get install -y patch
RUN apt-get install -y libtool-bin
COPY ./crosstool-ng /home/crosstool-ng
WORKDIR /home/crosstool-ng
RUN ./bootstrap
RUN CXXFLAGS=-intl ./configure --prefix=$PWD/../crosstool-ng-build
RUN make
RUN make install
RUN apt-get install -y wget
COPY ./crosstool-ng-workspace /home/crosstool-ng-workspace
WORKDIR /home/crosstool-ng-workspace
RUN ../crosstool-ng-build/bin/ct-ng build
RUN mv /home/crosstool-ng-workspace/opt /
RUN ls -lisah /opt/cross
ENV PATH="/opt/cross/bin:${PATH}"
WORKDIR /home/
ENTRYPOINT bash
CMD "--help"
