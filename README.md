<h2>macOS -> RasPi Cross Compilation Toolchain
  <img src="http://zeezide.com/img/rpi-swift.svg?2"
       align="right" width="180" height="180" />
</h2>

![Swift3](https://img.shields.io/badge/swift-3-blue.svg)
![tuxOS](https://img.shields.io/badge/os-Xenial-green.svg?style=flat)
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
compiler toolchain for the Raspberry Pi (armhf) Ubuntu Xenial port.

What this is good for?
You can build Raspberry Pi Swift binaries on a Mac. Like this:
```
mkdir helloworld && cd helloworld
swift package init --type=executable
swift build --destination /tmp/cross-toolchain/rpi-ubuntu-xenial-destination.json
file .build/debug/helloworld
.build/debug/helloworld: ELF 32-bit LSB executable, ARM, 
                         EABI5 version 1 (SYSV), dynamically linked, 
                         interpreter /lib/ld-linux-armhf.so.3, 
                         for GNU/Linux 3.2.0, not stripped
```

(We also have a toolchain kit which does the reverse, compile macOS Swift 
 binaries on a Raspberry Pi: [macos](macos/README.md))

## Building the ARM toolchain

What we are going to do is build a Swift 3.1.1 cross compilation toolchain
for ARM Ubuntu Xenial.
Note that we are going to use the Swift 4 package manager, but the Swift 3.1
compiler (because Swift 4 on Raspi is not in shape yet).

Requirements:
- Xcode 9 or later (http://developer.apple.com/)
- a Raspi 3 w/ Ubuntu [xyz]

### Build Toolchain using Script

First download our script and make it executable:
[build_rpi_ubuntu_cross_compilation_toolchain](https://raw.githubusercontent.com/helje5/dockSwiftOnARM/master/toolchain/build_rpi_ubuntu_cross_compilation_toolchain),
e.g. like:

```
pushd /tmp
curl https://raw.githubusercontent.com/helje5/dockSwiftOnARM/master/toolchain/build_rpi_ubuntu_cross_compilation_toolchain \
  | sed "s/$(printf '\r')\$//" \
  > build_rpi_ubuntu_cross_compilation_toolchain
chmod +x build_rpi_ubuntu_cross_compilation_toolchain
```

You can just call the script and it'll give you instructions, but let's just
go ahead.
Next step is to download Swift 3.1.1 tarballs. 
We need the macOS pkg for the host compiler and a Raspberry Pi tarball for the
Swift runtime. We use the one provided by Florian Friedrich for the latter:

```
pushd /tmp
curl -o /tmp/swift-3.1.1-armv7l-ubuntu16.04.tar.gz https://cloud.sersoft.de/nextcloud/index.php/s/0qty8wJxlgfVCcx/download
curl -o /tmp/swift-3.1.1-RELEASE-osx.pkg https://swift.org/builds/swift-3.1.1-release/xcode/swift-3.1.1-RELEASE/swift-3.1.1-RELEASE-osx.pkg
```
Those are a little heavy (~400 MB), so grab a 🍺 or 🍻.
Once they are available, build the actual toolchain using the script:

```
pushd /tmp
./build_rpi_ubuntu_cross_compilation_toolchain \
  /tmp/ \
  /tmp/swift-3.1.1-RELEASE-osx.pkg \
  /tmp/swift-3.1.1-armv7l-ubuntu16.04.tar.gz
```

If everything worked fine, it'll end like that:
```
OK, your cross compilation toolchain for Raspi Ubuntu Xenial is now ready to be used
 - SDK: /tmp/cross-toolchain/rpi-ubuntu-xenial.sdk
 - toolchain: /tmp/cross-toolchain/swift.xctoolchain
 - SwiftPM destination.json: /tmp/cross-toolchain/rpi-ubuntu-xenial-destination.json
```

### Step 3: Use the Toolchain

Lets create a simple `helloworld` tool first:

```
mkdir helloworld && cd helloworld
swift package init --type=executable
swift build --destination /tmp/cross-toolchain/rpi-ubuntu-xenial-destination.json
```

Which gives:
```
Compile Swift Module 'helloworld' (1 sources)
Linking ./.build/debug/helloworld
```

Check whether it actually produced an ARM binary:
```
file .build/debug/helloworld
.build/debug/helloworld: ELF 32-bit LSB executable, ARM, EABI5 version 1 (SYSV), dynamically linked, interpreter /lib/ld-linux-armhf.so.3, for GNU/Linux 3.2.0, not stripped
```

Excellent! It worked. Now either copy your binary to a Raspi or test it using
QEmu as described below.

If you are not using our 
[Docker image](https://hub.docker.com/r/helje5/rpi-swift/),
you may need to setup the `LD_LIBRARY_PATH`, so that the dynamic linker finds
the Swift runtime. E.g. like that:

```
sudo cat > /etc/ld.so.conf.d/swift.conf <<EOF
/usr/lib/swift/linux
/usr/lib/swift/clang/lib/linux
/usr/lib/swift/pm
EOF
sudo ldconfig
```

## Testing builds using Docker on macOS

Docker for Mac comes with QEmu support enabled, meaning that you can run
simple ARM binaries without an actual Raspberry Pi.

```
docker run --rm --tty -i -v "$PWD/.build/debug/:/home/swift" \
  helje5/rpi-swift:3.1.1 \
  ./helloworld
```

This works for simple builds, more complex stuff does not run in QEmu. Use
a proper Pi for that :-)

## OK, no README w/o 🐄🐄🐄

Lets build something very useful, an ASCII cow generator.
The snapshot's `swift package init` produces a Swift 4 setup by default.
We want to use 3.1, so we do the setup manually:

```
mkdir vaca && cd vaca
cat > Package.swift <<EOF
import PackageDescription

let package = Package(
  name: "vaca",
  dependencies: [
    .Package(url: "https://github.com/AlwaysRightInstitute/cows.git",
             majorVersion: 1, minor: 0)
  ]
)
EOF

cat > main.swift <<EOF
import cows
print(vaca())
EOF
```

Then build the thing:

```
swift build \
  --destination /tmp/cross-toolchain/rpi-ubuntu-xenial-destination.json
Fetching https://github.com/AlwaysRightInstitute/cows.git
Cloning https://github.com/AlwaysRightInstitute/cows.git
Resolving https://github.com/AlwaysRightInstitute/cows.git at 1.0.1
Compile Swift Module 'cows' (3 sources)
Compile Swift Module 'vaca' (1 sources)
Linking ./.build/debug/vaca
```

And you get the most awesome Swift tool:

```
docker run --rm --tty -i -v "$PWD/.build/debug/:/home/swift" \
           helje5/rpi-swift:3.1.1 ./vaca
   (___)
   (o o)
  __\_/__
 //^^*^^\
 /   *   \
/ |  *  | \
\ |=====| /
 "|_____|"
   | | |
   | | |
   |_|_|
    ^ ^
   COWNT
```

Wanna have Server Side Cows on the Pi? Try this:
[mod_swift](http://mod-swift.org/raspberrypi/).

Having the cows on your Raspi is not enough?
Get: [CodeCows](https://itunes.apple.com/de/app/codecows/id1176112058)
and [ASCII Cows](https://itunes.apple.com/de/app/ascii-cows/id1176152684).

## Notes of interest

- SwiftPM reuses the `.build` directory even if you call it w/ 
  different destinations. So make sure you clean before building for a
  different architecture.
- Ubuntu system headers and such for the toolchain are directly pulled
  from the Debian packages (which are retrieved from the Ubuntu repository)
- The cross compiler is just a regular clang/swiftc provided as part of
  a macOS toolchain. Yes, clang/swift are always setup as cross compilers
  and can produce binaries for all supported targets! (didn't know that)
- To trace filesystem calls on macOS you can use `fs_usage`, e.g.:
  `sudo fs_usage -w -f pathname swift` (I only knew `strace` ;-)

### Who

Brought to you by
[The Always Right Institute](http://www.alwaysrightinstitute.com)
and
[ZeeZide](http://zeezide.de).
We like feedback, GitHub stars, cool contract work,
presumably any form of praise you can think of.
We don't like people who are wrong.

There is the [swift-arm](https://slackpass.io/swift-arm) Slack channel
if you have questions about running Swift on ARM/Raspberry Pi.
