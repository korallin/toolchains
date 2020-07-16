dockername=zoop_toolchain_build-alpine
docker rm $dockername
docker build -f ./build-alpine.Dockerfile -t $dockername:latest .
docker create --name $dockername $dockername:latest
docker_out_tar_name=docker-${dockername}-out.tar
docker cp $dockername:/opt - > $docker_out_tar_name
mkdir -p ./opt/cross
echo "tar -xf $docker_out_tar_name --no-same-owner --preserve-permissions -C ./"
tar -xf $docker_out_tar_name --no-same-owner --preserve-permissions -C ./
echo "tar -caf cross-armv6l-gcc.tar.gz opt/cross"
tar -caf cross-armv6l-gcc.tar.gz opt/cross
chmod -R 777 ./opt/cross
rm -rf ./opt $docker_out_tar_name
