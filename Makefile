.DEFAULT_GOAL := build

BASE_DIR ?= ${CURDIR}

IMAGE_TAG_NAME ?= "arkivum/nextcloud"
IMAGE_TAG_VERSION ?= "latest"

all: clean build

build: build-files-move-app build-nextcloud-image

build-files-move-app:
	# Build the 'files_mv' NextCloud app
	@mkdir -p "$(BASE_DIR)/build"
	@if [ ! -f build/files_mv/appinfo/info.xml ] ; then \
		docker run --rm \
			--volume "$(BASE_DIR)/src/:/src:ro" \
			--volume "$(BASE_DIR)/build:/build" \
			--workdir "/src/" \
			--env BUILD_OWNER=$(shell id -u):$(shell id -g) \
			python \
			./files_mv/build.sh ; \
	fi

build-nextcloud-image:
	# Build NextCloud docker image
	@docker build -t "$(IMAGE_TAG_NAME):$(IMAGE_TAG_VERSION)" .

clean:
	# Remove build artefacts
	@rm -Rf "$(BASE_DIR)/build"

.PHONY: all build build-files-move-app build-nextcloud-image clean
