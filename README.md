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

```shell
docker run --rm  helje5/rpi-swift swift --version
Swift version 3.1 (swift-3.1-RELEASE)
Target: armv7-unknown-linux-gnueabihf
```

REPL fails despite `--privileged`:

```shell
docker run   --privileged=true --rm --interactive --tty helje5/rpi-swift   swift 
error: failed to stop process at REPL breakpoint
```

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
We like feedback, GitHub stars,
presumably any form of praise you can think of.
We don't like people who are wrong.
