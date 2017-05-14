<h2>RasPi -> macOS  Cross Compilation Toolchain
  <img src="http://zeezide.com/img/rpi-swift.svg?2"
       align="right" width="180" height="180" />
</h2>

![Swift3](https://img.shields.io/badge/swift-3-blue.svg)
![tuxOS](https://img.shields.io/badge/os-Xenial-green.svg?style=flat)
![ARM](https://img.shields.io/badge/cpu-ARM-red.svg?style=flat)

So, I got that new late-2016 MacBook Pro (yes, the touchbar is aweful,
except for the 
[Lemmings](https://github.com/erikolsson/Touch-Bar-Lemmings),
those are cool).
Everyone knows that with just 16GB of RAM it isn't really a Pro machine and
you can hardly do any work on it.
As an occasional Swift developer who also 
[runs the Slack app](https://twitter.com/helje5/status/771699792808386560)
once in a while
I'm always looking for ways to workaround that frustrating limitation.

So while working on the cross-compiler toolchain which allows you to compile
Swift code for the Raspberry Pi on a Mac (read about it [here](../README.md)),
a brilliant idea was formed:

> "The real question is can you cross compile to macOS from your Raspberry Pi
> build fleet"<br>
> *ducks*

That of course is the solution. Instead of bothering the Mac to produce Swift
binaries for the Mac, why not cross compile the Swift code for the Mac on one 
of the Raspberry Pis sitting around in the house, usually idle.

Like that:

<img src="http://zeezide.com/img/raspi2mac.gif" />


## Building the macOS toolchain for ARM

What we are going to do is build a Swift 3.1.1 cross compilation toolchain
running on ARM Ubuntu Xenial, targetting macOS.

This is a little harder that the [Mac to Raspi cross compiler](../README.md),
but still reasonably easy.

### Step 1: Prepare toolchain on the Mac

Before switching to the Raspi, we need to grab system headers and libraries
from the Mac.
We also need to convert the Swift 3.1.1 toolchain for Mac to a tarball
(for whatever reason I couldn't get `xar` to run on ARM - works fine on x86-64).

Grab macOS system headers and libs:
```
(cd /; tar zcf /tmp/x-macos-linux-x86_64-usr.tar.gz usr/lib usr/include)"
```

Download the Swift 3.1.1 Mac toolchain and convert it to a tarball
(use our `extract-toolchain-pkg-to-tar.sh` to do the latter):
```
curl -o /tmp/swift-3.1.1-RELEASE-osx.pkg \
  https://swift.org/builds/swift-3.1.1-release/xcode/swift-3.1.1-RELEASE/swift-3.1.1-RELEASE-osx.pkg
./extract-toolchain-pkg-to-tar.sh \
  /tmp/swift-3.1-RELEASE-osx.pkg \
  /tmp/swift-3.1-RELEASE-osx.tar.gz
```

Transfer the two files to your Raspi, e.g. using `scp`:
```
scp /tmp/x-macos-linux-x86_64-usr.tar.gz \
    /tmp/swift-3.1-RELEASE-osx.tar.gz \
    pirate@black-pearl.local:/tmp
```


### Step 2: Build Toolchain using Script

On the Raspi we first need to make sure we have some packages necessary
for the build:

```bash
sudo apt-get install -y bison libxml2-dev cpio lsb-release libssl-dev
```

Next download our toolchain script onto your Raspi and make it executable:
[build-rpi-ubuntu-2-macos-x-toolchain](https://raw.githubusercontent.com/helje5/dockSwiftOnARM/master/toolchain/macosx/build-rpi-ubuntu-2-macos-x-toolchain),
e.g. like:

```bash
pushd /tmp
curl https://raw.githubusercontent.com/helje5/dockSwiftOnARM/master/toolchain/macosx/build-rpi-ubuntu-2-macos-x-toolchain \
  | sed "s/$(printf '\r')\$//" \
  > build-rpi-ubuntu-2-macos-x-toolchain
chmod +x build-rpi-ubuntu-2-macos-x-toolchain
```

You can call the script and it'll give you instructions, but let's just
go ahead.
Next step is to download Swift 3.1.1 tarballs. 
We need the macOS toolchain tarballs we created in Step 1
and a Raspberry Pi tarball for the Swift compiler. 
We use the one provided by Florian Friedrich for the latter:

```bash
pushd /tmp
curl -o /tmp/swift-3.1.1-armv7l-ubuntu16.04.tar.gz https://cloud.sersoft.de/nextcloud/index.php/s/0qty8wJxlgfVCcx/download
```

Once those are available, build the actual toolchain using the script:

```bash
pushd /tmp
./build-rpi-ubuntu-2-macos-x-toolchain \
  /tmp/ \
  /tmp/swift-3.1.1-armv7l-ubuntu16.04.tar.gz
  /tmp/swift-3.1.1-RELEASE-osx.tar.gz \
  /tmp/x-macos-darwin-x86_64-usr.tar.gz
```

It takes about 20 minutes on a Raspi 3b, so grab a 🍺 or 🍻 while you wait.
If everything worked fine, it'll end like that:
```
OK, your cross compilation toolchain for macOS is now ready to be used
 - SDK: /tmp/cross-toolchain/MacOSX.sdk
 - toolchain: /tmp/cross-toolchain/swift.xctoolchain
 - SwiftPM destination.json: /tmp/cross-toolchain/macos-destination.json
```


### Step 3: Install a recent Swift Package Manager

To use the cross compilation support, we need a pretty recent Swift Package
Manager.
On a regular x86-64 Ubuntu or macOS we could just grab a snapshot,
but the Swift project doesn't yet provide such for Raspberry Pis.

Instead we are going to fetch a recent Swift Package Manager,
but use it with the Swift 3.1 installation.

```bash
git clone https://github.com/apple/swift-package-manager.git
cd swift-package-manager
git checkout 5c88e044abb8943598749d2e95007605e0660377
swift build -c release
```

*Note*: We are indeed building a 3.1.1 toolchain! We are just using a new
        Swift Package Manager.

Subsequently I assume you are using my 
[helje5/rpi-swift-dev](https://hub.docker.com/r/helje5/rpi-swift-dev/) 
Docker image.
If you are using a different setup, adjust as necessary.

Integrate the SPM we just built into the existing Swift setup:

```bash
sudo mv /usr/bin/swift-build   /usr/bin/swift-build.org
sudo mv /usr/bin/swift-test    /usr/bin/swift-test.org
sudo mv /usr/bin/swift-package /usr/bin/swift-package.org
sudo mv /usr/lib/swift/pm/PackageDescription.swiftmodule \
        /usr/lib/swift/pm/PackageDescription.swiftmodule.org

sudo mkdir -p /usr/lib/swift/pm/3 /usr/lib/swift/pm/4

sudo cp .build/release/swift-*       /usr/bin/
sudo cp .build/release/libclibc.so   /usr/lib/swift/pm/
sudo cp .build/release/*.so          /usr/lib/swift/pm/3/
sudo cp .build/release/*.so          /usr/lib/swift/pm/4/
sudo cp .build/release/PackageDescription.swiftmodule  /usr/lib/swift/pm/3/
sudo cp .build/release/PackageDescription4.swiftmodule /usr/lib/swift/pm/4/
sudo cp .build/release/PackageDescription4.swiftmodule \
        /usr/lib/swift/pm/4/PackageDescription.swiftmodule
sudo ldconfig
```

After that your environment should look like this:
```bash
swift@xyz: swift --version
Swift version 3.1.1 (swift-3.1.1-RELEASE)
Target: armv7-unknown-linux-gnueabihf

swift@xyz: swift build --version
Swift Package Manager - Swift 4.0.0-dev
```


### Step 4: Use the Toolchain

Lets create a simple `helloworld` tool first. We cannot use
`swift package init` here, because we want to setup a Swift 3 module,
not a Swift 4 one.

```bash
mkdir helloworld && cd helloworld

cat > Package.swift <<EOF
import PackageDescription
let package = Package(name: "helloworld")
EOF

echo 'print("Hello World!")' > main.swift

swift build --destination /tmp/cross-toolchain/macos-destination.json
```

Which gives:
```
Compile Swift Module 'helloworld' (1 sources)
Linking ./.build/debug/helloworld
```

Check whether it actually produced a MACH-O (macOS) binary:
```
file .build/debug/helloworld
.build/debug/helloworld: Mach-O 64-bit x86_64 executable
```

Excellent! It worked. Copy your binary to a Mac and run it! :-)

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
swift build --destination /tmp/cross-toolchain/macos-destination.json
Fetching https://github.com/AlwaysRightInstitute/cows.git
Cloning https://github.com/AlwaysRightInstitute/cows.git
Resolving https://github.com/AlwaysRightInstitute/cows.git at 1.0.1
Compile Swift Module 'cows' (3 sources)
Compile Swift Module 'vaca' (1 sources)
Linking ./.build/debug/vaca
```

Copy it over from your Raspi to a Mac and you get the most awesome Swift tool:

```
helge@ZeeMBP ~ $ ./vaca 
----------
|\         \
|  ----------
|  |  (__)  |
\  |  (oo)  |
 \ |   \/   |
   ----------
    Ice Cowbe
```

Wanna have Server Side Cows on the Pi? Try this:
[mod_swift](http://mod-swift.org/raspberrypi/).

Having the cows on your Raspi is not enough?
Get: [CodeCows](https://itunes.apple.com/de/app/codecows/id1176112058)
and [ASCII Cows](https://itunes.apple.com/de/app/ascii-cows/id1176152684).


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
