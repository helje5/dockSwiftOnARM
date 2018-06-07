<h2>dockSwiftOnARM
  <img src="http://zeezide.com/img/rpi-swift.svg?2"
       align="right" width="180" height="180" />
</h2>

![Swift3](https://img.shields.io/badge/swift-3-blue.svg)
![tuxOS](https://img.shields.io/badge/os-tuxOS-green.svg?style=flat)
![ARM](https://img.shields.io/badge/cpu-ARM-red.svg?style=flat)
<a href="https://slackpass.io/swift-arm"><img src="https://img.shields.io/badge/Slack-swift/arm-red.svg?style=flat"/></a>

Playing with dockerizing Swift for Raspberry Pi.

Inspired by
[uraimo/buildSwiftOnARM](https://github.com/uraimo/buildSwiftOnARM).

Also note the companion project:
[swift-mac2arm-x-compile-toolchain](https://github.com/AlwaysRightInstitute/swift-mac2arm-x-compile-toolchain),
a cross compiler toolchain which allows you to build Raspi Swift binaries
on macOS (and the reverse for the fun of it!).

### Running Swift w/ Docker on macOS

Works:

```shell
docker run --rm  helje5/rpi-swift swift --version
Swift version 3.1 (swift-3.1-RELEASE)
Target: armv7-unknown-linux-gnueabihf
```

There is also an image which includes Emacs, vi, etc:
```shell
docker run -it --rm  helje5/rpi-swift-dev bash
```

Note that the REPL doesn't work on the Raspi.

DockerHub:
- [rpi-swift](https://hub.docker.com/r/helje5/rpi-swift/)
- [rpi-swift-dev](https://hub.docker.com/r/helje5/rpi-swift-dev/) 
  (w/ Emacs/vi/etc)
  
Want to run Server Side Swift on a Raspberry Pi? Use
[mod_swift](http://mod-swift.org/raspberrypi/).

#### Versions

As of 2018-04-05 the latest working Swift version for Raspi is Swift 3.1.1.

We do provide a docker image for 4.1.0. It basically works, but isn't stable
(e.g. crashes on some operations). It also doesn't include the Swift Package
Manager.

### Setup Raspi w/ Docker and remote-control it from macOS

Moved to Wiki:
- [Setup Docker on Raspi](https://github.com/helje5/dockSwiftOnARM/wiki/Setup-Docker-on-Raspi)
- [Remote Control Raspi Docker from Mac](https://github.com/helje5/dockSwiftOnARM/wiki/Remote-Control-Raspi-Docker) (via docker-machine)

### Building Swift w/ Docker on macOS

Moved to Wiki:
- [Building Swift in a Docker container](https://github.com/helje5/dockSwiftOnARM/wiki/Building-Swift-with--Docker) (either on a real Raspi or in macOS Docker QEmu)

### Status

No idea, still investigating this :-)

### Who

Brought to you by
[The Always Right Institute](http://www.alwaysrightinstitute.com).
We like 
[feedback](https://twitter.com/ar_institute), 
GitHub stars, 
cool [contract work](http://zeezide.com/en/services/services.html),
presumably any form of praise you can think of.
We don't like people who are wrong.

There is the [swift-arm](https://slackpass.io/swift-arm) Slack channel
if you have questions about running Swift on ARM/Raspberry Pi.
