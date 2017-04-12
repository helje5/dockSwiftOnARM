# Makefile

all : build-rpi-swift build-rpi-swift-dev # build-rpi-swift-build302

build-rpi-swift :
	docker build -t helje5/rpi-swift \
		     -f rpi-swift-ctx/rpi-swift.dockerfile \
		     rpi-swift-ctx
	docker images | grep helje5

build-rpi-swift-dev : build-rpi-swift
	docker build -t helje5/rpi-swift-dev \
		     -f empty-ctx/rpi-swift-dev.dockerfile \
		     empty-ctx
	docker images | grep helje5

# ---------------------------

build-rpi-swift-build302 : # build-rpi-raspbian-swift-build302-env
	docker build -t helje5/rpi-swift-build \
                     --no-cache \
		     -f empty-ctx/rpi-swift-build.dockerfile \
		     empty-ctx
	docker images | grep helje5/rpi-swift-build

# A basic setup containing the necessary packages to build Swift
# (clang and such, also sets clang as the compiler)
build-rpi-raspbian-swift-build-env :
	docker build -t helje5/rpi-raspbian-swift-build-env \
	       	     -f empty-ctx/rpi-raspbian-swift-build-env.dockerfile \
		     empty-ctx
	docker images | grep helje5/rpi-raspbian-swift-build-env

# contains the 3.0.2 Swift Sources
build-rpi-raspbian-swift-build302-env : build-rpi-raspbian-swift-build-env
	docker build -t helje5/rpi-raspbian-swift-build302-env \
	       	     -f rpi-swift-302-ctx/rpi-raspbian-swift-build302-env.dockerfile \
		     rpi-swift-302-ctx
	docker images | grep helje5/rpi-raspbian-swift-build302-env


# ---------------------------

list :
	docker images | grep helje5

swift-version :
	docker run --rm helje5/rpi-swift bash -c "uname -a; swift --version"

run :
	docker run --rm --interactive --tty helje5/rpi-swift


fetch-swift-tarballs :
	wget https://www.dropbox.com/s/kmu5p6j0otz3jyr/swift-3.0.2-RPi23-RaspbianNov16.tgz

publish :
	docker push helje5/rpi-swift
	docker push helje5/rpi-swift-dev
