# Makefile

#all : # build-rpi-swift build-rpi-swift-dev # build-rpi-swift-build302
all : build-rpi-swift-31 build-rpi-swift-31-dev

PACKAGE_TARGET_DIR=/tmp

build-rpi-swift-31 :
	time docker build -t helje5/rpi-swift:latest -t helje5/rpi-swift:3.1.0 \
		     -f rpi-swift-3.1.0-ctx/rpi-ubuntu-swift-3.1.0.dockerfile \
		     rpi-swift-3.1.0-ctx
	docker images | grep helje5

build-rpi-swift-31-dev : 
	time docker build -t helje5/rpi-swift-dev:latest \
	             -t helje5/rpi-swift-dev:3.1.0  \
		     -f empty-ctx/rpi-swift-3.1.0-dev.dockerfile \
		     empty-ctx
	docker images | grep helje5

build-rpi-swift-302 :
	docker build -t helje5/rpi-swift \
		     -f rpi-swift-302-ctx/rpi-raspbian-swift-302.dockerfile \
		     rpi-swift-302-ctx
	docker images | grep helje5

build-rpi-swift-dev : build-rpi-swift
	docker build -t helje5/rpi-swift-dev \
		     -f empty-ctx/rpi-raspbian-swift302-dev.dockerfile \
		     empty-ctx
	docker images | grep helje5

build-rpi-mod_swift-demo :
	time docker build -t modswift/rpi-mod_swift-demo:latest \
	             -t modswift/rpi-mod_swift-demo:3.1.0  \
		     -f empty-ctx/rpi-mod_swift-demo.dockerfile \
		     empty-ctx
	docker images | grep modswift

build-rpi-mod_swift-demo-dev :
	time docker build -t modswift/rpi-mod_swift-demo-dev:latest \
	             -t modswift/rpi-mod_swift-demo-dev:3.1.0  \
		     -f empty-ctx/rpi-mod_swift-demo-dev.dockerfile \
		     empty-ctx
	docker images | grep modswift

# ---------------------------

EXTRAFLAGS=
ifeq ($(nocache),yes)
EXTRAFLAGS += --no-cache
endif

# -v $(PACKAGE_TARGET_DIR):/package \
# is non-sense here ... Do not build an image, but rather run a script in the
# Ubuntu base docker ...
build-rpi-ubuntu-swift31-build : # build-rpi-raspbian-swift-build302-env
	time docker build -t helje5/rpi-ubuntu-swift31-build \
                     $(EXTRAFLAGS) \
		     -f empty-ctx/rpi-ubuntu-swift31-build.dockerfile \
		     empty-ctx
	docker images | grep helje5/rpi-ubuntu-swift31

build-rpi-swift-build302 : # build-rpi-raspbian-swift-build302-env
	time docker build -t helje5/rpi-swift-build \
                     $(EXTRAFLAGS) \
		     -f empty-ctx/rpi-raspbian-swift302-build.dockerfile \
		     empty-ctx
	docker images | grep helje5/rpi-swift-build

# A basic setup containing the necessary packages to build Swift
# (clang and such, also sets clang as the compiler)
build-rpi-raspbian-swift-build-env :
	time docker build -t helje5/rpi-raspbian-swift-build-env \
	       	     -f empty-ctx/rpi-raspbian-swift-build-env.dockerfile \
		     empty-ctx
	docker images | grep helje5/rpi-raspbian-swift-build-env

# A basic setup containing the necessary packages to build Swift
# (clang and such, also sets clang as the compiler)
build-rpi-ubuntu-swift-build-env :
	time docker build -t helje5/rpi-ubuntu-swift-build-env \
                     $(EXTRAFLAGS) \
	       	     -f empty-ctx/rpi-ubuntu-swift-build-env.dockerfile \
		     empty-ctx
	docker images | grep helje5/rpi-ubuntu-swift-build-env

# contains the 3.0.2 Swift Sources
build-rpi-raspbian-swift-build302-env : build-rpi-raspbian-swift-build-env
	time docker build -t helje5/rpi-raspbian-swift-build302-env \
	       	     -f rpi-swift-302-ctx/rpi-raspbian-swift-build302-env.dockerfile \
		     rpi-swift-302-build-ctx
	docker images | grep helje5/rpi-raspbian-swift-build302-env

# contains the 3.1 Swift Sources
build-rpi-ubuntu-swift-build31-env : build-rpi-ubuntu-swift-build-env
	time docker build -t helje5/rpi-ubuntu-swift-build31-env \
	       	     -f rpi-swift-31-ctx/rpi-ubuntu-swift-build31-env.dockerfile \
		     rpi-swift-31-build-ctx
	docker images | grep helje5/rpi-ubuntu-swift-build31-env

# contains the 3.1.1 Swift Sources
build-rpi-ubuntu-swift-build311-env :
	time docker build -t helje5/rpi-ubuntu-swift-build311-env \
	       	     -f rpi-swift-3.1.1-ctx/rpi-ubuntu-swift-build31-env.dockerfile \
		     rpi-swift-31-build-ctx
	docker images | grep helje5/rpi-ubuntu-swift-build31-env


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
