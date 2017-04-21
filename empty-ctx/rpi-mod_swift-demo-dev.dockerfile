# Dockerfile
#
# docker run -i --tty --rm -p 8042:8042 helje5/rpi-mod_swift-demo-dev
#
FROM helje5/rpi-mod_swift-demo

# rpi-swift sets it to swift
USER root

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get install -y vim emacs make wget sudo


# setup sudo

RUN adduser swift sudo
RUN echo 'swift ALL=(ALL:ALL) ALL' > /etc/sudoers.d/swift
RUN chmod 0440 /etc/sudoers.d/swift
RUN echo 'swift:swift' | chpasswd


USER swift
WORKDIR /home/swift

CMD bash
