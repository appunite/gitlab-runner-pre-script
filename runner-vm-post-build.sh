#!/bin/bash

ruby <(curl -fsSL https://git.appunite.com/szymon.mrozek/macos-image-dependencies/raw/master/post_intest_report.rb) || true
