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

Current Build Issue is:
```
Step 7/7 : RUN ./build.sh
 ---> Running in 7319556b76d4
Traceback (most recent call last):
  File "./swift/utils/build-script", line 27, in <module>
    from SwiftBuildSupport import (
  File "/swiftsrc/swift/utils/SwiftBuildSupport.py", line 26, in <module>
    from swift_build_support import diagnostics  # noqa (E402)
ImportError: cannot import name diagnostics
```

I'm not exactly sure why, everything kinda looks OK. But it doesn't work in
Python either:
```
root@8f60be757fc5:/swiftsrc# python
Python 2.7.9 (default, Sep 17 2016, 20:26:04) 
[GCC 4.9.2] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> import sys, os
>>> sys.path = ['/swiftsrc/swift/utils', '/usr/lib/python2.7', '/usr/lib/python2.7/plat-arm-linux-gnueabihf', '/usr/lib/python2.7/lib-tk', '/usr/lib/python2.7/lib-old', '/usr/lib/python2.7/lib-dynload', '/usr/local/lib/python2.7/dist-packages', '/usr/lib/python2.7/dist-packages', './swift/utils', '/swiftsrc/swift/utils/swift_build_support']
>>> from swift_build_support import diagnostics
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
ImportError: cannot import name diagnostics
```


### Status

No idea, still investigating this :-)

### Who

Brought to you by
[The Always Right Institute](http://www.alwaysrightinstitute.com).
We like feedback, GitHub stars,
presumably any form of praise you can think of.
We don't like people who are wrong.
