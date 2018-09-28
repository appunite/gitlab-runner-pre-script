#!/bin/bash

if [ -z $SKIP_RUNNER_CACHE ]; then 
	echo "--- Uploading cache started..."
	# check if AUTO_CLOSE_TOKEN is not nil
	if [ -z $AUTO_CLOSE_TOKEN ]; then
		echo "--- AUTO_CLOSE_TOKEN variable is unset, exiting..."
		exit 0
	fi

	PODS_ARCHIVE="Pods.tar.bz2"
	GEMS_ARCHIVE="Gems.tar.bz2"
	PODS_PATH="Pods"
	BUNDLE_PATH="vendor/bundle"
	CACHE_PATH="/mnt/cache/${CI_RUNNER_ID}/${CI_PROJECT_NAME}"

	PODS_CHECKSUM_PATH="$CACHE_PATH/Podfile.checksum"
	PODFILE_LOCK_CHECKSUM=`test -s Podfile.lock && md5 -q Podfile.lock`
	test -e $PODS_CHECKSUM_PATH || touch $PODS_CHECKSUM_PATH

	BUNDLE_CHECKSUM_PATH="$CACHE_PATH/Gemfile.checksum"
	GEMFILE_LOCK_CHECKSUM=`test -s Gemfile.lock && md5 -q Gemfile.lock`
	test -e $BUNDLE_CHECKSUM_PATH || touch $BUNDLE_CHECKSUM_PATH

	# create folder
	mkdir -p $CACHE_PATH
	if [ -e $PODS_PATH ] && [ "$PODFILE_LOCK_CHECKSUM" != "$(cat $PODS_CHECKSUM_PATH)" ]; then
		echo "--- Caching pods..."
		time tar -c $PODS_PATH | pbzip2 -c | openssl enc -e -aes-256-cbc -k $AUTO_CLOSE_TOKEN -out $PODS_ARCHIVE
		time cp $PODS_ARCHIVE $CACHE_PATH && echo $PODFILE_LOCK_CHECKSUM > $PODS_CHECKSUM_PATH
	fi

	if [ -e $BUNDLE_PATH ] && [ "$GEMFILE_LOCK_CHECKSUM" != "$(cat $BUNDLE_CHECKSUM_PATH)" ]; then
		echo "--- Caching gems..."
		time tar -c $BUNDLE_PATH | pbzip2 -c | openssl enc -e -aes-256-cbc -k $AUTO_CLOSE_TOKEN -out $GEMS_ARCHIVE
		time cp $GEMS_ARCHIVE $CACHE_PATH && echo $GEMFILE_LOCK_CHECKSUM > $BUNDLE_CHECKSUM_PATH
	fi

else
	echo "--- Skipping runner cache uploading"
fi
