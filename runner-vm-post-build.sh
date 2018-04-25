#!/bin/bash

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

# create folder
mkdir -p $CACHE_PATH

if [ -e $PODS_PATH ]; then
	echo "--- Caching pods..."
	time tar -c $PODS_PATH | pbzip2 -c | openssl enc -e -aes-256-cbc -k $AUTO_CLOSE_TOKEN -out $PODS_ARCHIVE
	time cp $PODS_ARCHIVE $CACHE_PATH

fi

if [ -e $BUNDLE_PATH ]; then
	echo "--- Caching gems..."
	time tar -c $BUNDLE_PATH | pbzip2 -c | openssl enc -e -aes-256-cbc -k $AUTO_CLOSE_TOKEN -out $GEMS_ARCHIVE
	time cp $GEMS_ARCHIVE $CACHE_PATH
fi

echo "--- Uploading cache finished..."

# print transfered data
#ls -lah *.bz2