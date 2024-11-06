#!/usr/bin/env bash

# Exit early if something goes wrong
set -e

# Add commands below to run inside the container after all the other buildpacks have been applied

export COPILOT_ENVIRONMENT_NAME='build'
rm ./config/application.yml
