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

Note that the REPL doesn't work on the Raspi.

DockerHub:
- [rpi-swift](https://hub.docker.com/r/helje5/rpi-swift/)
- [rpi-swift-dev](https://hub.docker.com/r/helje5/rpi-swift-dev/) 
  (w/ Emacs/vi/etc)
  
Want to run Server Side Swift on a Raspberry Pi? Use
[mod_swift](http://mod-swift.org/raspberrypi/).

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

<table width="100%" border="0">
  <tr>
    <td align="center" width="20%">
      <a href="http://apacheexpress.io"
        ><img src="http://zeezide.com/img/ApexIcon128.png" width="64" height="64" /></a>
    	<br />
    	ApacheExpress
    </td>
    <td align="center" width="20%">
      <a href="http://mod-swift.org"
        ><img src="http://zeezide.com/img/mod_swift-128x128.png" width="64" height="64" /></a>
    	<br />
    	mod_swift
    </td>
    <td align="center" width="20%">
      <a href="http://zeeql.io"
        ><img src="http://zeezide.com/img/ZeeQLIconQL128.png" width="64" height="64" /></a>
      <br />
      ZeeQL
    </td>
    <td align="center" width="20%">
      <a href="http://noze.io"
        ><img src="https://pbs.twimg.com/profile_images/725354235056017409/poiNAOlB_400x400.jpg" width="64" height="64" /></a>
      <br />
      Noze.io
    </td>
    <td align="center" width="20%">
      <a href="https://github.com/ZeeZide/UXKit"
        ><img src="http://zeezide.com/img/UXKitIcon1024.png" width="64" height="64" /></a>
      <br />
      UXKit
    </td>
  </tr>
</table>
