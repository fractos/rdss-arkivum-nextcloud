FROM wonderfall/nextcloud

MAINTAINER Arkivum Limited

# Copy the files_mv app to NextCloud
COPY build/files_mv /nextcloud/apps/files_mv

# Replace the default setup.sh with our own
COPY rootfs/usr/local/bin/arkivum-setup.sh /usr/local/bin/arkivum-setup.sh
RUN mv /usr/local/bin/setup.sh /usr/local/bin/base-setup.sh && \
    ln -s /usr/local/bin/arkivum-setup.sh /usr/local/bin/setup.sh
