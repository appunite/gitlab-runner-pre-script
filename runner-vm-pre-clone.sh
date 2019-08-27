#!/bin/bash

echo -e "--- Updating time&date..."
sudo systemsetup setusingnetworktime off > /dev/null 2>&1
sudo sntp -sS time.apple.com > /dev/null 2>&1
date

echo -e "--- Updating CA cert..."
sudo curl -kfsSL curl.haxx.se/ca/cacert.pem -o "$(ruby -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_FILE')"

echo -e "--- System version:"
sw_vers

echo -e "--- Dig git.appunite.com"
dig git.appunite.com

echo -e "--- Add git.appunite.com to hosts"
sudo -- sh -c "echo 136.243.171.167 git.appunite.com >> /etc/hosts"

echo -e "--- Sleep for a while"
sleep 15

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

echo -e "--- Installed software:"
ruby <(curl -fsSL https://git.appunite.com/szymon.mrozek/macos-image-dependencies/raw/master/get_depfile.rb) --type yaml || true
ruby <(curl -fsSL https://git.appunite.com/szymon.mrozek/macos-image-dependencies/raw/master/post_depfile.rb) &>/dev/null &
