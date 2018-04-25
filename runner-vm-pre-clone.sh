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

# Set bigger post buffer because of early EOF issue 
# https://stackoverflow.com/questions/24952683/git-push-error-rpc-failed-result-56-http-code-200-fatal-the-remote-end-hun?rq=1

git config --global http.postBuffer 524288000