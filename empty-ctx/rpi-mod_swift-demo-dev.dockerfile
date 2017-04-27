# Dockerfile
#
#   docker run -i --tty --rm -p 8042:8042 modswift/rpi-mod_swift-demo-dev
#
#   LD_LIBRARY_PATH="$PWD/.libs:$LD_LIBRARY_PATH" \
#     EXPRESS_VIEWS=mods_expressdemo/views apache2 \
#     -X -d $PWD -f apache-ubuntu.conf
#
FROM modswift/rpi-mod_swift-demo

# rpi-swift sets it to swift
USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y vim emacs make wget sudo


# setup sudo # TODO: sounds like we are supposed to use gosu instead

RUN adduser swift sudo
RUN echo 'swift ALL=(ALL:ALL) ALL' > /etc/sudoers.d/swift
RUN chmod 0440 /etc/sudoers.d/swift
RUN echo 'swift:swift' | chpasswd


USER swift

ARG MOD_SWIFT_VERSION=0.7.6
WORKDIR /home/swift/mod_swift-$MOD_SWIFT_VERSION

CMD bash
