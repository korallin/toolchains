#sudo apt install autoconf
cd ./crosstool-ng
./bootstrap
CXXFLAGS=-intl ./configure --prefix=$PWD/../crosstool-ng-build
make
make install
cd ../crosstool-ng-workspace
../crosstool-ng-build/bin/ct-ng build
tar -cavf cross-armv6l-gcc.tar.gz opt/cross
chmod -R 777 ./opt/cross
rm -rf ./opt
mv cross-armv6l-gcc.tar.gz ..
