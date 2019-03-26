# Makefile

CLOWN_URL="https://github.com"
SWIFT_ARM_HERO="futurejones"
PKG_DOWNLOAD_URL="$(CLOWN_URL)/$(SWIFT_ARM_HERO)/swift-arm64/releases/download"

SWIFTVERSION="5.0"
BUILDDATE="2019-03-26"
SWIFT_FULL_VERSION="$(SWIFTVERSION).0"

SWIFT_OS="ubuntu"
SWIFT_OS_CAP="Ubuntu"
SWIFTOSVERSION="16.04"
SWIFT_CPU="aarch64"

DOCKER_USER="helje5"
DOCKER_CPU="arm64v8"
DOCKER_IMAGE_NAME="$(DOCKER_CPU)-swift"
DOCKER_FULL_VERSION_TAG=$(SWIFT_FULL_VERSION)
DOCKER_LATEST_TAG=$(SWIFTVERSION)-latest

DERIVED_TARBALL="v$(SWIFTVERSION)-$(SWIFT_OS)-$(SWIFTOSVERSION)/swift-$(SWIFTVERSION)-$(SWIFT_CPU)-RELEASE-$(SWIFT_OS_CAP)-$(SWIFTOSVERSION)_$(BUILDDATE).tar.gz"

all:
	@echo "use 'fetch' target to fetch tarball"
	@echo "use 'build' target to build"

fetch :
	wget $(PKG_DOWNLOAD_URL)/$(DERIVED_TARBALL)

build:
	time docker build \
	     -t helje5/$(DOCKER_IMAGE_NAME):$(DOCKER_FULL_VERSION_TAG)	\
	     -t helje5/$(DOCKER_IMAGE_NAME):$(DOCKER_LATEST_TAG)		\
	     -f $(DOCKER_CPU)-$(SWIFT_OS)-$(SWIFTOSVERSION)-swift-$(SWIFT_FULL_VERSION).dockerfile \
	     $(PWD)
	docker images | grep $(DOCKER_USER)/$(DOCKER_CPU)

publish:
	time docker push $(DOCKER_USER)/$(DOCKER_IMAGE_NAME):$(DOCKER_FULL_VERSION_TAG)
	time docker push $(DOCKER_USER)/$(DOCKER_IMAGE_NAME):$(DOCKER_LATEST_TAG)
