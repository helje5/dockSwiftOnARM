<h2>Raspi Cross Compilation Toolchain
  <img src="http://zeezide.com/img/rpi-swift.svg?2"
       align="right" width="180" height="180" />
</h2>

![Swift3](https://img.shields.io/badge/swift-3-blue.svg)
![tuxOS](https://img.shields.io/badge/os-tuxOS-green.svg?style=flat)
![ARM](https://img.shields.io/badge/cpu-ARM-red.svg?style=flat)

End of April
[Johannes Weiß](https://github.com/weissi)
added
[custom toolchain support](https://github.com/apple/swift-package-manager/pull/1098)
to 
[Swift Package Manager](https://github.com/apple/swift-package-manager).

Johannes also provided 
[a script](https://github.com/apple/swift-package-manager/blob/master/Utilities/build_ubuntu_cross_compilation_toolchain)
which shows how to build an Ubuntu toolchain for x86-64.

So what we did is take that script and make it produce a Swift 3.1.1 cross 
compiler toolchain for the RaspberryPi (armhf) Ubuntu Xenial port.

What this is good for?
You can build RaspberryPi Swift binaries on a Mac:
```
mkdir helloworld && cd helloworld
swift package init --type=executable
swift build --destination /tmp/cross-toolchain/rpi-ubuntu-xenial-destination.json
file .build/debug/helloworld
.build/debug/my-test-app: ELF 32-bit LSB executable, ARM, 
                          EABI5 version 1 (SYSV), dynamically linked, 
                          interpreter /lib/ld-linux-armhf.so.3, 
                          for GNU/Linux 3.2.0, not stripped
```

### Building the ARM toolchain

What we are going to do is build a Swift 3.1.1 cross compilation toolchain
for ARM Ubuntu Xenial.

#### Step 1: Install recent Swift Snapshot

To do this, we need to install a recent version of Swift Package Manager.
And the easiest way to do this, is to install a recent 
[Swift snapshot](https://swift.org/download/#snapshots).
We tried `swift-DEVELOPMENT-SNAPSHOT-2017-05-09-a`:
[Download](https://swift.org/builds/development/xcode/swift-DEVELOPMENT-SNAPSHOT-2017-05-09-a/swift-DEVELOPMENT-SNAPSHOT-2017-05-09-a-osx.pkg).
Download the Xcode package and install it on your Mac.

*Note*: Snapshots require macOS 10.12, they do not run on macOS 10.11.

*Note*: We are indeed building a 3.1.1 toolchain! We are just using the
        Swift Package Manager from the snapshot.

The next step is to enable the swift tools from that snapshot. I use 
[swiftenv](https://swiftenv.fuller.li/en/latest/installation.html#via-homebrew)
for that, if you don't have it:

```
brew install kylef/formulae/swiftenv
echo 'if which swiftenv > /dev/null; then eval "$(swiftenv init -)"; fi' >> ~/.bash_profile
eval "$(swiftenv init -)"
```

And then enable the snapshot (use `swiftenv versions` to list the ones you
have available):

```
swiftenv global DEVELOPMENT-SNAPSHOT-2017-05-09-a
```

OK, good to go :-)

#### Step 2: Build Toolchain using Script

```
./build_rpi_ubuntu_cross_compilation_toolchain \
  /tmp/ \
  ~/Downloads/swift-3.1.1-RELEASE-osx.pkg \
  ~/Downloads/swift-3.1.1-armv7l-ubuntu16.04.tar.gz
```

TODO

### Testing builds using Docker on macOS

Docker for Mac comes with QEmu support enabled, meaning that you can run
simple ARM binaries without an actual RaspberryPi.

```
docker run --rm --tty -i -v $PWD:/host helje5/rpi-swift:3.1.1 \
       /host/.build/debug/helloworld 
```

This works for simple builds, more complex stuff does not run in QEmu. Use
a proper Pi for that :-)


### Notes of interest

- SwiftPM reuses the name `.build` directory even if you call it w/ 
  different destinations. So make sure you clean before building for a
  different architecture.
- Ubuntu system headers and such for the toolchain are directly pulled
  from the Debian packages
- The cross compiler is just a regular clang/swiftc provided as part of
  a macOS toolchain. Yes, clang/swift are always setup as cross compilers
  and can produce binaries for all supported targets! (didn't know that)
- To trace filesystem calls on macOS you can use `fs_usage`, e.g.:
  `sudo fs_usage -w -f pathname swift` (only new `strace` ;-)

### Who

Brought to you by
[The Always Right Institute](http://www.alwaysrightinstitute.com)
and
[ZeeZide](http://zeezide.de).
We like feedback, GitHub stars, cool contract work,
presumably any form of praise you can think of.
We don't like people who are wrong.

There is the [swift-arm](https://slackpass.io/swift-arm) Slack channel
if you have questions about running Swift on ARM/RaspberryPis.
