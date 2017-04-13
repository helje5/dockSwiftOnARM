<h2>dockSwiftOnARM
  <img src="http://zeezide.com/img/rpi-swift.svg?2"
       align="right" width="180" height="180" />
</h2>

![Swift3](https://img.shields.io/badge/swift-3-blue.svg)
![tuxOS](https://img.shields.io/badge/os-tuxOS-green.svg?style=flat)
![ARM](https://img.shields.io/badge/cpu-ARM-red.svg?style=flat)

Playing with dockerizing Swift for Raspberry Pi.

Inspired by
[uraimo/buildSwiftOnARM](https://github.com/uraimo/buildSwiftOnARM).

### Running Swift w/ Docker on macOS

Note: Not completely working yet, but a little:

    helge@ZeeMBP raspi (master)*$ docker run \
      --privileged=true --rm --interactive --tty helje5/rpi-swift 
    root@bef83fb586d9:/# swift --version
    Swift version 3.0.2 (swift-3.0.2-RELEASE)
    Target: armv7--linux-gnueabihf

REPL still crashes despite `--privileged`:

    helge@ZeeMBP raspi (master)$ docker run --privileged=true --rm --interactive --tty helje5/raspian-swift 
    root@e3cdb56fe385:/# swift
    error: failed to launch REPL process: process launch failed: 'A' packet returned an error: 8

### Setup Raspi w/ Docker and remote-control it from macOS

- on the Mac (replace XYZ wit the disk number)
  - [Download Hypriot](https://blog.hypriot.com/downloads/) image
  - unzip
  - insert an empty SD card into your Mac
  - diskutil list
  - diskutil unmountdisk /dev/diskXYZ
  - sudo dd if=~/Downloads/hypriotos-rpi-v1.4.0.img of=/dev/diskXYZ bs=1m
  - diskutil unmountdisk /dev/diskXYZ
- insert Hypriot SD card into RaspberryPi, connect to network, then power
- on the Mac
  - find zPi3 IP address
    - grab your IP (e.g. ipconfig getifaddr en0)
    - nmap -sP THE-IP-ADDRESS/24 | grep black-pearl
  - ssh-copy-id pirate@zpi3 (default password is hypriot)
  - ssh pirate@THE-IP-ADDRESS
    - docker info
    - change password

- on the Mac, patch Hypriot to work with docker-machine: [001-fix](https://github.com/DieterReuter/arm-docker-fixes/tree/master/001-fix-docker-machine-1.8.0-create-for-arm): 

```bash
ssh pirate@THE-IP-ADDRESS \
  "curl -sSL https://github.com/DieterReuter/arm-docker-fixes/raw/master/001-fix-docker-machine-1.8.0-create-for-arm/apply-fix-001.sh | bash"`
```

- tweet a a success message to @Quintus23M

- on the Mac, connect to Raspi via docker-machine:

```bash
docker-machine create \
  --driver=generic --engine-storage-driver=overlay \
  --generic-ip-address=THE-IP-ADDRESS \
  --generic-ssh-user=pirate raspberry

docker-machine ls
```

- direct the docker client to the RaspberryPi and run commands:

```bash
eval $(docker-machine env zpi3)
docker images
docker ps
docker run --rm helje5/rpi-swift swift --version
```

### Building Swift w/ Docker on macOS

I also tried to actually build Swift itself based on 
[Umberto's instructions](https://github.com/uraimo/buildSwiftOnARM),
but didn't quite get it running yet. Pull requests are very welcome :-)

In this setup I pulled the Swift sources separately on macOS (they are huge)
and added some layers to avoid installing them again and again 
(rpi-swift-302-ctx etc).

The stack:

- `rpi-raspbian-swift-build-env` is `resin/rpi-raspbian` w/ the
  build dependencies
- `rpi-raspbian-swift-build302-env` just adds in the (unpatched) Swift sources
- `rpi-swift-build` then tries to build it

#### How to build Swift via macOS Docker:

First build the Raspbian docker w/ all the tools required to build Swift:

    make build-rpi-raspbian-swift-build-env

Next fetch the Swift sources, this takes a LONG time, they are HUGE:

    ./grab-swift.sh

This results in a tarball `swift-checkout-$date.tar.bz2` which contains the
`swift-checkout` directory. It contains a checkout of all the Swift sources,
unpatched, HEAD.

So we want to produce another tarball containing a specific Swift version,
that is `swift-3.0.2-RELEASE` or `swift-3.1-RELEASE`:

    ./make-swift-branch-tarball.sh swift-checkout swift-3.0.2-RELEASE

That gives you `swift-3.0.2-RELEASE.tgz`, which you move into 
`rpi-swift-302-ctx`. The context directory is uploaded to Docker everytime
you build an image, so keep it small ...
This one is almost 1GB in size!

The script *modifies* the `swift-checkout` directory. 
If you build another branch tarball, 
delete `swift-checkout` and recreate from the 
`swift-checkout-$date.tar.bz2` you got from `grab-swift.sh`.

Create another Docker image which is `helje5/rpi-raspbian-swift-build-env`
plus just the sources (added to `/swiftsrc/`):

    make build-rpi-raspbian-swift-build302-env

Finally, trigger the actual build:

    make build-rpi-swift-build302

And hope.
(I'm told that it takes 7 hours on a Raspi2 and 8 DAYS on a Raspi1 :-)


#### Update 2017-04-13

The build takes about a day in the emulator, I was hoping it would be roughly
the same speed (running on a MacPro), but it isn't.

The same process also works when it is triggered in the Raspi, remote
controlled from macOS. That build runs about 7 hours on a Raspi3, but
eventually breaks with:

```
--- bootstrap: note: building stage1: /swiftsrc/build/buildbot_linux/llbuild-linux-armv7/bin/swift-build-tool -f /swiftsrc/build/buildbot_linux/swiftpm-linux-armv7/.bootstrap/build.swift-build
*** Error in `/swiftsrc/build/buildbot_linux/llbuild-linux-armv7/bin/swift-build-tool': malloc(): memory corruption: 0x76c3257e ***
--- bootstrap: error: build failed with exit status -6
./swift/utils/build-script: fatal error: command terminated with a non-zero exit status 1, aborting
```

I think this is the state from which
[uraimo/buildSwiftOnARM](https://github.com/uraimo/buildSwiftOnARM)
creates the tarball we currently use in helje5/rpi-swift / helje5/rpi-swift-dev.
At this point pretty much everything is built, including Foundation.
But Swift Package Manager cores with the malloc issue.


### Status

No idea, still investigating this :-)

### Who

Brought to you by
[The Always Right Institute](http://www.alwaysrightinstitute.com).
We like feedback, GitHub stars,
presumably any form of praise you can think of.
We don't like people who are wrong.
