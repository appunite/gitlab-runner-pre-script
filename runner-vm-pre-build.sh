#!/bin/bash

if [ -z $SKIP_RUNNER_CACHE ]; then
	echo "--- Downloading cache started..."
	# check if AUTO_CLOSE_TOKEN is not nil
	if [ -z $AUTO_CLOSE_TOKEN ]; then
		echo "--- AUTO_CLOSE_TOKEN variable is unset, exiting..."
		exit 0
	fi

	MOUNT_PATH="/mnt/cache"
	if [ ! -d "$MOUNT_PATH" ]; then
		echo "--- Creating mount point at $MOUNT_PATH..."
		sudo mkdir -p $MOUNT_PATH
		sudo chown -R vagrant $MOUNT_PATH

		# check if AUTO_CLOSE_TOKEN is not nil
		if [ -z $NFS_SERVER ] || [ -z $NFS_PATH]; then
			echo "--- NFS_SERVER/NFS_PATH variable is unset, exiting..."
			exit 0
		fi

		echo "--- Mounting NFS folder from $NFS_SERVER..."
		sudo mount -t nfs -o resvport,nosuid,rw,hard,intr,timeo=900,actimeo=2,proto=tcp $NFS_SERVER:$NFS_PATH $MOUNT_PATH
	fi

	#
	PODS_ARCHIVE="Pods.tar.bz2"
	GEMS_ARCHIVE="Gems.tar.bz2"
	CACHE_PATH="$MOUNT_PATH/${CI_RUNNER_ID}/${CI_PROJECT_NAME}"
	
	PODS_CHECKSUM_PATH="$CACHE_PATH/Podfile.checksum"
	PODFILE_LOCK_CHECKSUM=`test -s Podfile.lock && md5 -q Podfile.lock`

	if [ -e ${CACHE_PATH}/${PODS_ARCHIVE} ] && [ "$PODFILE_LOCK_CHECKSUM" == "$(cat $PODS_CHECKSUM_PATH)" ]; then
		echo "--- Loading pods cache..."
		time cp ${CACHE_PATH}/${PODS_ARCHIVE} $PODS_ARCHIVE
		time openssl enc -aes-256-cbc -k $AUTO_CLOSE_TOKEN -d -in $PODS_ARCHIVE | pbzip2 -dc | tar xf -
	else
	  echo "--- Skipping Pods cache. Podfile.lock checksum is not valid anymore."
	fi

	BUNDLE_CHECKSUM_PATH="$CACHE_PATH/Gemfile.checksum"
	GEMFILE_LOCK_CHECKSUM=`test -s Gemfile.lock && md5 -q Gemfile.lock`
	
	if [ -e ${CACHE_PATH}/${GEMS_ARCHIVE} ] && [ "$GEMFILE_LOCK_CHECKSUM" == "$(cat $BUNDLE_CHECKSUM_PATH)" ]; then
		echo "--- Loading gems cache..."
		time cp ${CACHE_PATH}/${GEMS_ARCHIVE} $GEMS_ARCHIVE
		time openssl enc -aes-256-cbc -k $AUTO_CLOSE_TOKEN -d -in $GEMS_ARCHIVE | pbzip2 -dc | tar xf -
	else
	  echo "--- Skipping Gems cache. Gemfile.lock checksum is not valid anymore."
	fi

	echo "--- Downloading cache finished..."
else
	echo "--- Skipping runner cache downloading"
fi
