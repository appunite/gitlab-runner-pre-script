#!/bin/bash

echo -e "--- Updating time&date..."
sudo systemsetup setusingnetworktime off > /dev/null 2>&1
sudo ntpdate -u time.apple.com > /dev/null 2>&1
date

echo -e "--- Updating CA cert..."
sudo curl -kfsSL curl.haxx.se/ca/cacert.pem -o "$(ruby -ropenssl -e 'puts OpenSSL::X509::DEFAULT_CERT_FILE')"

echo -e "--- CPU:"
sysctl -n machdep.cpu.brand_string

echo -e "--- Swift version:"
xcrun swift -version

echo -e "--- Xcodebuild version:"
xcodebuild -version

# Set bigger post buffer because of early EOF issue and increase alive interval
# https://docs.gitlab.com/ee/topics/git/troubleshooting_git.html#increase-the-post-buffer-size-in-git

cat <<EOF >>~/.ssh/config

echo "Increasing alive interval / count max"
Host git.appunite.com
  ServerAliveInterval 60
  ServerAliveCountMax 5
EOF

git config --global http.postBuffer 1048576000