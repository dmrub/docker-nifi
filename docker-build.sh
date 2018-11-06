#!/bin/bash

set -e

THIS_DIR=$( (cd "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) )

IMAGE_PREFIX=${IMAGE_PREFIX:-nifi}
IMAGE_TAG=${IMAGE_TAG:-1.8.0}
IMAGE_NAME=${IMAGE_PREFIX}:${IMAGE_TAG}

set -e

export LC_ALL=C
unset CDPATH

set -x
docker build $NO_CACHE -t "${IMAGE_NAME}" "$THIS_DIR"
set +x
echo "Successfully built docker image $IMAGE_NAME"
