# Docker Firefly-iii

[Firefly-iii](https://www.firefly-iii.org/) A free and open source personal finance manager.

This is a custom Firefly III Docker Image build on top of linuxserver.io `lsiobase/nginx` but not supported by linuxserver.io.

This Image was optimized for systems with low resources and contains the following differences from the official Image:

- Nginx instead of Apache
- Nginx with 1 worker
- PHP FPM with 1 worker
- Only supports MySQL
- No HTTPS

## The official docker image can be found at https://github.com/firefly-iii/docker

## Supported Architectures

Simply pulling `fabiodcorreia/firefly-iii` should retrieve the correct image for your arch, but you can also pull specific arch images via tags.

The architectures supported by this image are:

| Architecture | Tag |
| :----: | --- |
| x86-64 | amd64-latest |
| arm64 | arm64v8-latest |
| armhf | arm32v7-latest |


## Usage

This image can be used running directly from docker cli or by docker-compose. It's also compatible with Kubernetes but no examples are provided.

### docker

```
docker create \
  --name=firefly-iii \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Europe/London \
  -e DB_HOST=mariadb_firefly \
  -e DB_DATABASE=fireflydb \
  -e DB_USERNAME=firefly_user \
  -e DB_PASSWORD=firefly_password \
  -p 3306:3306 \
  -v path_to_data:/config \
  --restart unless-stopped \
  fabiodcorreia/firefly-iii
```

### docker-compose
An example can be found on the [repository](https://github.com/fabiodcorreia/docker-fireflyiii/blob/master/docker-compose.yml).

# -------------BELOW IS IN PROGRESS---------------

## Parameters

Container images are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 3306` | Mariadb listens on this port. |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e MYSQL_ROOT_PASSWORD=ROOT_ACCESS_PASSWORD` | Set this to root password for installation (minimum 4 characters). |
| `-e TZ=Europe/London` | Specify a timezone to use EG Europe/London. |
| `-e MYSQL_DATABASE=USER_DB_NAME` | Specify the name of a database to be created on image startup. |
| `-e MYSQL_USER=MYSQL_USER` | This user will have superuser access to the database specified by MYSQL_DATABASE (do not use root here). |
| `-e MYSQL_PASSWORD=DATABASE_PASSWORD` | Set this to the password you want to use for you MYSQL_USER (minimum 4 characters). |
| `-e REMOTE_SQL=http://URL1/your.sql,https://URL2/your.sql` | Set this to ingest sql files from an http/https endpoint (comma seperated array). |
| `-v /config` | Contains the db itself and all assorted settings. |


## User / Group Identifiers

When using volumes (`-v` flags) permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id user` as below:

```
  $ id username
    uid=1000(dockeruser) gid=1000(dockergroup) groups=1000(dockergroup)
```


&nbsp;
## Application Setup

If you didn't set a password during installation, (see logs for warning) use
`mysqladmin -u root password <PASSWORD>`
to set one at the docker prompt...

NOTE changing the MYSQL_ROOT_PASSWORD variable after the container has set up the initial databases has no effect, use the mysqladmin tool to change your mariadb password.

NOTE if you want to use (MYSQL_DATABASE MYSQL_USER MYSQL_PASSWORD) **all three** of these variables need to be set you cannot pick and choose.

Unraid users, it is advisable to edit the template/webui after setup and remove reference to this variable.

Find custom.cnf in /config for config changes (restart container for them to take effect)
, the databases in /config/databases and the log in /config/log/myqsl

### Loading passwords and users from files

The `MYSQL_ROOT_PASSWORD MYSQL_DATABASE MYSQL_USER MYSQL_PASSWORD REMOTE_SQL` env values can be set in a file:

```
/config/env
```

Using the following format:

```
MYSQL_ROOT_PASSWORD="ROOT_ACCESS_PASSWORD"
MYSQL_DATABASE="USER_DB_NAME"
MYSQL_USER="MYSQL_USER"
MYSQL_PASSWORD="DATABASE_PASSWORD"
REMOTE_SQL="http://URL1/your.sql,https://URL2/your.sql"
```

These settings can be mixed and matched with Docker ENV settings as you require, but the settings in the file will always take precedence.

## Support Info

* Shell access whilst the container is running: `docker exec -it mariadb /bin/bash`
* To monitor the logs of the container in realtime: `docker logs -f mariadb`
* container version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' mariadb`
* image version number
  * `docker inspect -f '{{ index .Config.Labels "build_version" }}' linuxserver/mariadb`

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (ie. nextcloud, plex), we do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.

Below are the instructions for updating containers:

### Via Docker Run/Create
* Update the image: `docker pull fabiodcorreia/firefly-iii`
* Stop the running container: `docker stop firefly-iii`
* Delete the container: `docker rm firefly-iii`
* Recreate a new container with the same docker create parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* Start the new container: `docker start firefly-iii`
* You can also remove the old dangling images: `docker image prune`

### Via Docker Compose
* Update all images: `docker-compose pull`
  * or update a single image: `docker-compose pull mariadb`
* Let compose update all containers as necessary: `docker-compose up -d`
  * or update a single container: `docker-compose up -d mariadb`
* You can also remove the old dangling images: `docker image prune`

### Via Watchtower auto-updater (especially useful if you don't remember the original parameters)
* Pull the latest image at its tag and replace it with the same env variables in one run:
  ```
  docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  containrrr/watchtower \
  --run-once mariadb
  ```

**Note:** We do not endorse the use of Watchtower as a solution to automated updates of existing Docker containers. In fact we generally discourage automated updates. However, this is a useful tool for one-time manual updates of containers where you have forgotten the original parameters. In the long term, we highly recommend using Docker Compose.

* You can also remove the old dangling images: `docker image prune`

