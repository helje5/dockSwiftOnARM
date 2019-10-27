# Swift Cross Compilation Toolchains

This project extends the work of [Johannes Weiss](https://github.com/weissi) and [Helge Heß](https://github.com/AlwaysRightInstitute/swift-mac2arm-x-compile-toolchain) to create MacOS cross-compilers which target Ubuntu on amd64 and arm64, respectively.  All real credit goes to them.

This version extends the previous work by:

1. adding targets for armv7 and armv6
2. incorporating Swift 5.1
3. creating a complete runtime library which can be used with Docker containers or natively to provide swift applications with precisely the libraries they were originally compiled with. 

IMO, the last point is the most important.  This makes is possible to deploy “distro-less” docker containers of your swift applications which are extremely small.  I am currently working on several R/Pi servers as examples which use this technique.

## Easy way to get started:

Just use the installers at: [github](https://github.com/CSCIX65G/SwiftCrossCompilers/releases).  Then skip the hard way immediately below and proceed directly to: `Using your cross-compiler`

## Hard way - Build your own: 

### Requirements
Homebrew coreutils and jq installed with:

    brew install coreutils jq

### Building the  toolchain on MacOS

To start, create the directory and fetch the code to do the build (it’s just a complicated bash script):

```
git clone https://github.com/CSCIX65G/SwiftCrossCompilers.git
cd SwiftCrossCompilers
```
To build an *arm64* cross compiler (for R/Pi 64-bit OSes):

    ./build_cross_compiler  Configurations/5.1.1-RELEASE/arm64.json

To build an *arm32v7* cross compiler (for R/Pi 32-bit OSes on armv7, e.g. R/Pi 2 and 3) *using the Ubuntu 18.04 runtime libs*:

    ./build_cross_compiler  Configurations/5.1.1-RELEASE/armv7-ubuntu.json
    
To build an *arm32v7* cross compiler (for R/Pi 32-bit OSes on armv7, e.g. R/Pi 2 and 3) *using the Raspbian Buster runtime libs*:

    ./build_cross_compiler  Configurations/5.1.1-RELEASE/armv7-raspbian.json

To build an *arm32v6* x-compiler from scratch is a much more complicated task.  As of now you would need to build an entire swift MacOS toolchain from source.  This toolchain must built with this 
(diff from @uraimo)[https://github.com/uraimo/buildSwiftOnARM/blob/master/swiftpm.diffs/armv6/001-v6target.diff]
applied. Then you need to make sure that you build the cross compiler incorporating your newly built swift toolchain.

Such a toolchain has been (provided here)[https://github.com/CSCIX65G/SwiftCrossCompilers/releases/download/5.1.1/swift-5.1.1-RELEASE-osx-armv6.pkg] . 

So if you are willing to use the pre-built toolchain,  To build an *arm32v6* x-compiler using the Raspbian Buster runtime libs, you can just say:

    ./build_cross_compiler  Configurations/5.1.1-RELEASE/armv6.json

We recommend just using the pre-builts as building your own mac-os swift toolchain with patch applied can be a very laborious and error-prone task.

To build an *amd64* cross compiler (for Ubuntu 18.04 running for example on cloud instances):

    ./build_cross_compiler  Configurations/5.1.1-RELEASE/amd64.json

Each call to the build script will take several minutes to complete. This is particularly true of the steps where it:

* fetches the toolchain 
* fetches and parses the Ubuntu package files and 
* builds the ld.gold linker 

When it does finish, you should get a message saying all is well and that the following directories: Toolchains, SDKs, and Destinations, have been populated with various (arm64|armhf|amd64) files have been produced.  Note that the armv6 and armv7 output are both named armhf internally.  This is a GNU/LLVM issue which can't really be addressed at this level.  

NB if you are building multiple x-compilers, you need to be very careful to clean things out under `./InstallPackagers/SwiftCrossCompiler/Developer` between builds.

The cross compilers end up under: `./InstallPackagers/SwiftCrossCompiler/Developer` by default.  If you don't want to make installer packages, you can simply copy the Toolchains, SDKs, Runtime and Destinations directories from there to `/Library/Developer`.  NB If you wish to change the installed location from `/Library/Developer` you will need to change the files under Destinations to match your new installed location.  Changes required in the file should be obvious.

If you do want to build your own installer package, you can get (Packages.app)[http://s.sudre.free.fr/Software/Packages/about.html] for free and open `./InstallPackagers/SwiftCrossCompiler/SwiftCrossCompiler.pkgproj`.  You'll want to adjust the version number SwiftCrossCompiler/Settings, then just use the Build/Build menu option.  The output will appear at `InstallPackagers/SwiftCrossCompiler/build/SwiftCrossCompiler.pkg`. Just double click that to install.

## Using your cross compiler
Assuming you have installed the cross compilers in /Library you can do the following from this directory.

    cd helloworld
    swift build --destination /Library/Developer/Destinations/arm64-5.1.1-RELEASE.json
    swift build --destination /Library/Developer/Destinations/amd64-5.1.1-RELEASE.json

If this finishes successfully you have an:
    
arm64 executable in `.build/aarch64-unknown-linux/debug/helloworld`
amd64 executable in `.build/x86_64-unknown-linux/debug/helloworld`  

You may then do one of the following.
    
    swift build --destination /Library/Developer/Destinations/armhf-5.1.1-ubuntu-RELEASE.son
    swift build --destination /Library/Developer/Destinations/armhf-5.1.1-raspbian-RELEASE.json
    /Library/Developer/Toolchains/armhf-5.1.1-RELEASE_armv6.xctoolchain/usr/bin/swift build --destination /Library/Developer/Destinations/armhf-5.1.1-armv6-RELEASE.json

You will then have an [armv7-ubuntu | armv7-raspbian | armv6] executable in `.build/armhf-unknown-linux/debug/helloworld`

Note that the reason you may only do one of the last 3 is that they all end up in  `.build/armhf-unknown-linux/debug/helloworld`. The first two are distinguished only by the set of shlibs they link to, the 3rd by the actual instruction set of armv6.  The name overlap is baked in to the way that Swift Package Manager manages its naming Triples (sorry but its not our fault).

The same techniques and commands as above may be used on any of your own code which compiles with the Swift Package Manager.

### Important information about Swift PM.

One key item to watch out for is that if you use `#if os(macos)` or `#if os(linux)` in your Package.swift file to, for example, fetch different dependencies which depend on the target x-compile architecture, you will not get the desired result.  The swiftpm fetch operations are running on the Mac in the case of the cross-compiler where with native compilation they are running on the Pi.  Since swift does not natively support cross-compilation (for non-Apple toolchains), you'll need to roll your own `#if` statements to properly fetch dependencies.

### Remote execution on a Raspberry Pi

Now type:

    ./build-arm64.sh

This will build the helloworld program and put it into a docker image called helloworld:arm64-latest.  Transport that container to the Pi along with the script `run-arm64.sh` .  That script will run and print "Successful launch!" at the console.

### Remote debugging on the Pi

Now for the more experimental stuff (I'm still debugging remote lldb):

On your mac type:

    /Library/Developer/Toolchains/arm64-swift.xctoolchain/usr/bin/lldb .build/aarch64-unknown-linux/debug/helloworld

This will produce an lldb prompt.   (NB, you must use the version of lldb that ships with the toolchain, not the Xcode default)

    env LD_LIBRARY_PATH=/swift-runtime//usr/lib/swift/linux:/swift-runtime/usr/lib/aarch64-linux-gnu:/swift-runtime/lib/aarch64-linux-gnu
    platform connect  connect://[IP or FQDN of your R/Pi]:9293

The first command tells the lldb-server running on your Pi where to find the swift runtime libraries. The last command should produce output similar to:

```
  Platform: remote-linux
    Triple: aarch64-*-linux-gnu
OS Version: 4.14.95 (4.14.95-hypriotos-v8)
    Kernel: #1 SMP PREEMPT Thu Jan 31 15:56:11 UTC 2019
  Hostname: e16dev-dev
 Connected: yes
WorkingDir: /debug
```

The first time you launch lldb you may need to say:
platform select remote-linux

Now say:

    run

(I find that sometimes you need exit lldb and rerun the steps above to get the remote process to launch successfully).

Running takes a while especially on first launch, because it has to copy the `helloworld` file to the R/Pi, but you should eventually see something like:

```
Process 32 launched: '.build/aarch64-unknown-linux/debug/helloworld' (aarch64)
Hello, world!
Process 32 exited with status = 0 (0x00000000) 
```

Congrats, you have built and remote debugged an arm64 executable on your Mac.


