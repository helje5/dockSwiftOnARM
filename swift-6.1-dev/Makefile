# Makefile

DOCKER_IMAGE=helje5/swift-dev
DOCKER_IMAGE_VERSION=6.1.0

# local config
SWIFT_BUILD=swift build
SWIFT_CLEAN=swift package clean
SWIFT_BUILD_DIR=.build
SWIFT_TEST=swift test
CONFIGURATION=release

# To build specific platforms:
# --platform linux/amd64
# --platform linux/amd64,linux/arm64

# docker config
DOCKER_BUILD_CONTEXT=desktop-linux
DOCKER_BUILD_DIR=".docker.build"
SWIFT_BUILD_IMAGE="swift:6.1"
DOCKER_BUILD_PRODUCT="$(DOCKER_BUILD_DIR)/$(TOOL_NAME)"
DOCKER_BUILD_TAG=$(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION)
DOCKER_BUILD_TAG_AMD64=$(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION)-amd64
DOCKER_BUILD_TAG_ARM=$(DOCKER_IMAGE):$(DOCKER_IMAGE_VERSION)-aarch64

DOCKERFILE=Dockerfile
DOCKER_PUBLISH_CONTEXT=desktop-linux

all:
	@echo "use 'make build' target to build"
	@echo "use 'make run'   to try the container"

docker-local-build:
	mkdir -p $(PWD)/empty-ctx
	time docker build \
	     --no-cache \
	     -t $(DOCKER_BUILD_TAG_ARM) \
	     -f $(DOCKERFILE) \
	     $(PWD)/empty-ctx
	docker images | grep $(DOCKER_IMAGE)

docker-build-multiplatform:
	time docker build \
	     --platform linux/amd64 \
	     --platform linux/aarch64 \
	     --no-cache \
	     -t $(DOCKER_BUILD_TAG) \
	     -f $(DOCKERFILE) \
	     $(PWD)/empty-ctx
	docker images | grep $(DOCKER_IMAGE)

docker-local-build-amd64:
	time docker build \
	     --platform linux/amd64 \
	     --no-cache \
	     -t $(DOCKER_BUILD_TAG_AMD64) \
	     -f $(DOCKERFILE) \
	     $(PWD)/empty-ctx
	docker images | grep $(DOCKER_IMAGE)



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
