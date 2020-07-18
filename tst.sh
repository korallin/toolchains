for f in docker/distros/*/*.tar.* ;\
  do \
      filename=$(basename $f) ;\
      url=$(echo 'https://uploads.github.com/repos/getzoop/cross-toolchains/releases/28696996/assets{?name,label}' | sed "s:{?name,label}:?name=$filename:");\
      echo curl --request POST \
      --url $url \
      --header 'authorization: Bearer a49624786639793ac1a5abba76927f8c6848888a' \
      --header 'content-type: application/gzip' \
      --form "data=@$f" ;\
  done

      #curl --request POST \
      #--url https://uploads.github.com/repos/getzoop/cross-toolchains/releases/28696996/assets?name=$filename \
      #--header 'authorization: Bearer a49624786639793ac1a5abba76927f8c6848888a' \
      #--header 'content-type: application/gzip' \
      #--form "data=@$f" ;\

