# Makefile

CLOWN_URL=https://github.com
SWIFT_ARM_HERO=futurejones
PKG_DOWNLOAD_URL="$(CLOWN_URL)/$(SWIFT_ARM_HERO)/swift-arm64/releases/download"

SWIFTVERSION=5.5
BUILDDATE=2021-10-29
BUILDREV=01
SWIFT_FULL_VERSION=$(SWIFTVERSION).1
SWIFT_BRANCH=RELEASE

SWIFT_OS=ubuntu
SWIFT_OS_CAP=Ubuntu
SWIFTOSVERSION=20.04
SWIFT_CPU=aarch64

DOCKER_USER=helje5
DOCKER_CPU=arm64v8
DOCKER_IMAGE_NAME="$(DOCKER_CPU)-swift"
DOCKER_FULL_VERSION_TAG=$(SWIFT_FULL_VERSION)
DOCKER_LATEST_TAG=$(SWIFTVERSION)-latest

#DERIVED_TARBALL="v$(SWIFTVERSION)-$(SWIFT_OS)-$(SWIFTOSVERSION)/swift-$(SWIFTVERSION)-$(SWIFT_CPU)-RELEASE-$(SWIFT_OS_CAP)-$(SWIFTOSVERSION)_$(BUILDDATE).tar.gz"
DERIVED_TARBALL="v$(SWIFT_FULL_VERSION)-$(SWIFT_BRANCH)/swiftlang-$(SWIFT_FULL_VERSION)-$(SWIFT_OS)-$(SWIFTOSVERSION)-release-$(SWIFT_CPU)-$(BUILDREV)-$(BUILDDATE).tar.gz"

all:
	@echo "use 'make fetch' target to fetch tarball"
	@echo "use 'make build' target to build"
	@echo "use 'make run'   to try the container"

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

run:
	docker run --rm --interactive --tty --name "swift-run" \
		$(DOCKER_USER)/$(DOCKER_IMAGE_NAME):$(DOCKER_FULL_VERSION_TAG)
