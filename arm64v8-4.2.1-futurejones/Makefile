# Makefile

all:
	@echo "use 'build' target"

build:
	time docker build -t helje5/arm64v8-swift:4.2.1 \
	     -f arm64v8-ubuntu-swift-4.2.1.dockerfile \
	     $(PWD)/../empty-ctx
	docker images | grep helje5/arm64v8

publish:
	time docker push helje5/arm64v8-swift:4.2.1
