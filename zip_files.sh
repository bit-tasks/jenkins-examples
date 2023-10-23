#!/bin/bash

# Ensure the downloads directory exists
mkdir -p downloads

# Create or overwrite the automating-component-releases.zip
zip -j downloads/automating-component-releases.zip \
    jenkins-files/bit-init \
    jenkins-files/commit-bitmap \
    jenkins-files/pull-request \
    jenkins-files/lane-cleanup \
    jenkins-files/tag-export \
    jenkins-files/verify

# Zip other individual files
zip -j downloads/branch-lane.zip jenkins-files/branch-lane
zip -j downloads/dependency-update.zip jenkins-files/dependency-update