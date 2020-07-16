#sudo apt install autoconf
sudo mkdir -p /opt/cross
sudo chown $USER /opt/cross
cd ./crosstool-ng
./bootstrap
./configure --prefix=$PWD/../crosstool-ng-build
make
make install
cd ../crosstool-ng-workspace
../crosstool-ng-build/bin/ct-ng build
