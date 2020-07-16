#sudo apt install autoconf
cd ./crosstool-ng
./bootstrap
CXXFLAGS=-intl ./configure --prefix=$PWD/../crosstool-ng-build
make
make install
cd ../crosstool-ng-workspace
../crosstool-ng-build/bin/ct-ng build

ENV PATH="/opt/cross/arm-armv6l-linux-gnueabi/bin:${PATH}"
 
