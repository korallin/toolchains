#sudo apt install autoconf
cd ./crosstool-ng
./bootstrap
cd ..
mkdir ./crosstool-ng-build
cd ./crosstool-ng-build
../crosstool-ng/configure --enable-local 
make
