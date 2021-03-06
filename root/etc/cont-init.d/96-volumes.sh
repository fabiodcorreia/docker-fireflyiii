#!/usr/bin/with-contenv bash

echo "**** start 96-volumes.sh ****"

# create directory structure
mkdir -p /config/www/upload
mkdir -p /config/www/logs
mkdir -p /config/www/export
mkdir -p $FIREFLY_PATH/storage/logs
mkdir -p $FIREFLY_PATH/storage/upload
mkdir -p $FIREFLY_PATH/storage/export

# create symlinks
symlinks=( \
    $FIREFLY_PATH/storage/logs
    $FIREFLY_PATH/storage/upload
    $FIREFLY_PATH/storage/export
)

for i in "${symlinks[@]}"
do
[[ -e "$i" && ! -L "$i" ]] && rm -rf "$i"
[[ ! -L "$i" ]] && ln -s /config/www/"$(basename "$i")" "$i"
done

# set permissions
chown -R abc:abc \
	/config \
	$FIREFLY_PATH/storage

echo "**** finish 96-volumes.sh ****"
