FROM scratch
MAINTAINER Van Simmons <van.simmons@computecycles.com>

VOLUME ["/lib", "/usr/lib"]

COPY ./.build/aarch64-unknown-linux/debug/helloworld ./helloworld

ENV LD_LIBRARY_PATH=/usr/lib/swift/linux:/usr/lib/aarch64-linux-gnu:/lib/aarch64-linux-gnu
ENTRYPOINT ["/lib/ld-linux-aarch64.so.1"]
CMD ["./helloworld"]

