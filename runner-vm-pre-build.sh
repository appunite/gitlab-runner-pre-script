#!/bin/bash

echo "Skipping runner cache downloading"
echo "moved to: https://git.appunite.com/appuniterd/ios/blob/master/bootstrap-project.md#makefile"

echo -e "--- Checking for outdated dependencies:"
ruby <(curl -fsSL https://git.appunite.com/szymon.mrozek/macos-image-dependencies/raw/master/outdated_dependencies.rb) || true
