# dockSwiftOnARM

Playing with dockerizing Swift for Raspberry Pi

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
