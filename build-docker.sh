dockername=zoop_toolchain_build-debian-buster
docker rm $dockername
docker build -f ./build-debian-buster.Dockerfile -t $dockername:latest .
docker create --name $dockername $dockername:latest
docker_out_tar_name=docker-out.tar
docker cp $dockername:/opt/cross - > $docker_out_tar_name
mkdir -p ./opt/cross
tar -xvf $docker_out_tar_name --no-same-owner --preserve-permissions -C ./opt/cross
tar -cavf cross-armv6l-gcc.tar.gz opt/cross
chmod -R 777 ./opt/cross
rm -rf ./opt $docker_out_tar_name
