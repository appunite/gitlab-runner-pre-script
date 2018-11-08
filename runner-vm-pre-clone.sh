#!/bin/bash

echo -e "--- Updating time&date..."
sudo systemsetup setusingnetworktime off > /dev/null 2>&1
sudo sntp -sS time.apple.com > /dev/null 2>&1
date

echo -e "--- Updating CA cert..."
sudo curl -kfsSL curl.haxx.se/ca/cacert.pem -o "$(ruby -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_FILE')"

echo -e "--- System version:"
sw_vers

echo -e "--- Disable System Integrity Protection"
csrutil disable

echo -e "--- Restarting mDNSResonder"
sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist
sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.mDNSResponder.plist

echo -e "--- Enable System Integrity Protection"
csrutil enable


echo -e "--- CPU:"
sysctl -n machdep.cpu.brand_string

echo -e "--- Swift version:"
xcrun swift -version

echo -e "--- Xcodebuild version:"
xcodebuild -version

# Set bigger post buffer because of early EOF issue and increase alive interval
# https://docs.gitlab.com/ee/topics/git/troubleshooting_git.html#increase-the-post-buffer-size-in-git

echo -e "--- Apply ssh config:"

cat <<EOF >>~/.ssh/config

Host git.appunite.com
  ServerAliveInterval 60
  ServerAliveCountMax 5
EOF

git config --global http.postBuffer 1048576000

cat ~/.ssh/config
