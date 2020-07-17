#sudo apt install autoconf
sudo mkdir -p /opt/cross
sudo chown $USER /opt/cross
cd ./crosstool-ng
./bootstrap
./configure --prefix=$PWD/../crosstool-ng-build
make
make install
cd ../ctng-workspace-arm-armv6l-linux-gnueabi
../crosstool-ng-build/bin/ct-ng build
