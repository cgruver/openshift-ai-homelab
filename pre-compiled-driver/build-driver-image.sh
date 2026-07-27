#!/usr/bin/env bash

CUDA_VERSION=${CUDA_VERSION:-13.0.2}
DRIVER_VERSION=${DRIVER_VERSION:-580.159.03}

. /etc/os-release
GIT_COMMIT=$(git describe --match="" --dirty --long --always --abbrev=40 2> /dev/null || echo "")
RHEL_VERSION=${VERSION_ID}
RHEL_VERSION_MAJOR=$(echo "${RHEL_VERSION}" | awk -F. '{print $$1}')
KERNEL_VERSION=$(uname -r)
BUILD_ARCH=$(uname -m)
TARGET_ARCH=$(echo "${BUILD_ARCH}" | sed "s/+64k//")
KERNEL_VERSION_NOARCH=$(echo "${KERNEL_VERSION}" | sed "s/\.${TARGET_ARCH}//")
KERNEL_VERSION_TAG=$(echo "${KERNEL_VERSION_NOARCH}.${BUILD_ARCH}" | sed "s/+/_/")
BASE_URL=https://us.download.nvidia.com/tesla

CUDA_DIST=ubi${RHEL_MAJOR}


DRIVER_TYPE=passthrough
DRIVER_OPEN=false
DRIVER_STREAM_TYPE=''

IMAGE_REGISTRY=${IMAGE_REGISTRY:-local}
IMAGE_NAME=driver
BUILDER_USER=$(git config --get user.name)
BUILDER_EMAIL=$(git config --get user.email)

podman build \
	--build-arg RHEL_VERSION=${RHEL_VERSION} \
	--build-arg RHEL_VERSION_MAJOR=${RHEL_VERSION_MAJOR} \
	--build-arg CUDA_VERSION=${CUDA_VERSION} \
	--build-arg CUDA_DIST=${CUDA_DIST} \
	--build-arg BUILD_ARCH=${BUILD_ARCH} \
	--build-arg TARGET_ARCH=${TARGET_ARCH} \
	--build-arg KERNEL_VERSION=${KERNEL_VERSION} \
	--build-arg KERNEL_VERSION_NOARCH=${KERNEL_VERSION_NOARCH} \
	--build-arg DRIVER_VERSION=${DRIVER_VERSION} \
	--build-arg DRIVER_EPOCH=${DRIVER_EPOCH} \
	--build-arg BUILDER_USER="${BUILDER_USER}" \
	--build-arg BUILDER_EMAIL=${BUILDER_EMAIL} \
	--build-arg DRIVER_TOOLKIT_IMAGE=${DRIVER_TOOLKIT_IMAGE} \
	--build-arg DRIVER_OPEN=${DRIVER_OPEN} \
	--build-arg DRIVER_TYPE=${DRIVER_TYPE} \
	--build-arg DRIVER_STREAM_TYPE=${DRIVER_STREAM_TYPE} \
	--build-arg BASE_URL=${BASE_URL} \
	--build-arg OS_TAG=${OS_TAG} \
	--build-arg GIT_COMMIT=${GIT_COMMIT} \
	--tag ${IMAGE_REGISTRY}/${IMAGE_NAME}:${DRIVER_VERSION}-${KERNEL_VERSION_TAG}-${OS_TAG} \
	--progress=plain \
	.


