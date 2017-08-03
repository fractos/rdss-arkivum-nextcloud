NextCloud Docker Container
===========================

Provides a [NextCloud](https://nextcloud.com/) Docker image based on [wonderfall/nextcloud](https://hub.docker.com/r/wonderfall/nextcloud/) with the following modifications:

* Added support for setting the `dbport` via environment variable `DB_PORT`
* The `files_external` plugin is enabled by default
* The [files_mv](https://github.com/eotryx/oc_files_mv/) plugin has been added and enabled
* The default skeleton files have been removed
* A trusted domain of `*` is added (you should use firewall to restrict access)

NextCloud is exposed on port 8888.

Building
---------

The build uses `make`. By default the `build` goal is executed. This also executes the `build-files-move-app` and `build-nextcloud-image` goals. The `clean` goal can be used to remove built files.

The build accepts the following build parameters:

| Parameter | Description | Default Value |
|---|---|---|
| `IMAGE_TAG_NAME` | The image name to tag the built Docker image with. | `arkivum/nextcloud` |
| `IMAGE_TAG_VERSION` | The version to tag the built Docker image with. | `latest` |

For example:

	make IMAGE_TAG_NAME="myorg/custom-nextcloud" IMAGE_TAG_VERSION="2.1"

Environment Variables
-----------------------

Most of the environment variables for this image are inherited from and [defined by `wonderfall/nextcloud`](https://github.com/Wonderfall/dockerfiles/tree/master/nextcloud#environment-variables).

In addition, the following are also supported:

| Variable | Description | Default Value |
|---|---|---|
| `DB_PORT` | Specifies the port to use to connect to the external database server. | `""` |
| `EXTERNAL_STORAGES` | Specifies the external storage location(s) that should be added as part of the set up. See [External Storage](#external-storage) below. | `""` |

External Storage
-----------------

To automatically configure external storage locations for NextCloud during setup, use the `EXTERNAL_STORAGES` environment variable. The value of this variable must be a space-separated string, with pairs of storage location names and paths. For example:

	docker run \
		--env EXTERNAL_STORAGES="docs:/mnt/docs music:/mnt/music" \
		--volume /home/rl/Documents:/mnt/docs \
		--volume /home/rl/Music:/mnt/music \
		arkivum/nextcloud

The above would instantitate the NextCloud container with two external storage locations defined: one for `docs` and one for `music`. In this example, volume mounts have been used to map folders on the host system to the folders in the container that have been referenced in the `EXTERNAL_STORAGES` value, creating external storage locations in NextCloud for the mounted paths on the host system.

This image only supports the creation of "local" external storage locations during setup. If the location you wish to use is remote, mount it on the docker host using normal mount operations (e.g. `mount -t cifs`) and then use that mounted directory as the host path for the docker volume mount.

Usage with Docker Compose
--------------------------

An example Docker Compose config for this image is as follows:

	version: '2'
	
	volumes:
		# Named volume for database persistence
		mysql_data:
	
		# Named volumes for NextCloud persistence
		nextcloud_apps:
		nextcloud_config:
		nextcloud_data:
		nextcloud_sessions:
		nextcloud_themes:
		
		# External storage locations
		my_docs:
			external: true
		my_music:
			external: true
	
	services:
	
		mysql:
			image: "percona:5.6"
			user: "mysql"
			environment:
				MYSQL_ROOT_PASSWORD: "12345"
			volumes:
				- "mysql_data:/var/lib/mysql"
			expose:
				- "3306"
	
		nextcloud:
			image: "arkivum/nextcloud"
			environment:
				ADMIN_USER: "admin"
				ADMIN_PASSWORD: "adminpassword"
				DB_HOST: "mysql"
				DB_USER: "root"
				DB_PASSWORD: "12345"
				DB_PORT: "3306"
				DB_TYPE: "mysql"
				GID: "1000"
				UID: "1000"
				EXTERNAL_STORAGES: "docs:/mnt/docs music:/mnt/music"
			volumes:
				# Nextcloud persistence
				- "nextcloud_apps:/apps2"
				- "nextcloud_config:/config"
				- "nextcloud_data:/data"
				- "nextcloud_themes:/nextcloud/themes"
				- "nextcloud_sessions:/php/session"
				# External storage
				- "my_docs:/mnt/docs"
				- "my_music:/mnt/music"
			ports:
				- "8888:8888"
			depends_on:
				- "mysql"
			links:
				- "mysql"

This configures NextCloud to use the provided MySQL service, and defines two external storage locations, `docs` and `music`, mapped to the `my_docs` and `my_music` named volumes.

Notice that the `my_docs` and `my_music` volumes are declared as `external`, meaning Docker Compose won't create them automatically. We therefore need to create these ourselves:

	docker volume create --opt type=none --opt o=bind --opt device=/home/rl/Documents my_docs
	docker volume create --opt type=none --opt o=bind --opt device=/home/rl/Music my_music

Using `docker volume` in this way means we can use normal mount operations to create the directory path we use to create the volume.
