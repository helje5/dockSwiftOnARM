# Makefile

PKG_DOWNLOAD_URL="https://github.com/futurejones/swift-arm64/releases/download"
SWIFTOS="ubuntu-18.04"
SWIFTVERSION="swift-5.0"
SNAPDATE="2018-12-26"

all:
	@echo "use 'fetch' target to fetch tarball"
	@echo "use 'build' target to build"

fetch :
	wget $(PKG_DOWNLOAD_URL)/$(SWIFTVERSION)-dev-$(SWIFTOS)-$(SNAPDATE)/$(SWIFTVERSION)-aarch64-DEV-18.04_$(SNAPDATE).tar.gz

build:
	time docker build \
	     -t helje5/arm64v8-swift:5.0dev-$(SNAPDATE) \
	     -t helje5/arm64v8-swift:5.0dev-latest \
	     -f arm64v8-ubuntu-swift-5.0dev.dockerfile \
	     $(PWD)
	docker images | grep helje5/arm64v8

publish:
	time docker push helje5/arm64v8-swift:5.0dev-$(SNAPDATE)
	time docker push helje5/arm64v8-swift:5.0dev-latest
