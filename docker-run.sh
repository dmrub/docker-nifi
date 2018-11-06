#!/bin/bash

THIS_DIR=$( (cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) )

IMAGE_PREFIX=${IMAGE_PREFIX:-nifi}
IMAGE_TAG=${IMAGE_TAG:-1.8.0}
IMAGE_NAME=${IMAGE_PREFIX}:${IMAGE_TAG}

cd "$THIS_DIR"

set -xe
docker run -p 8080:8080 \
       --name=nifi \
       --rm -ti "${IMAGE_NAME}" "$@"
