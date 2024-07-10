FROM fedora:latest
ENV OS_NAME=fedora
RUN dnf makecache \
    && dnf install -y gcc gcc-c++ make cmake wayland-devel libxkbcommon-devel libXcursor-devel libXi-devel libXinerama-devel libXrandr-devel
VOLUME /root/dandelion-dev
VOLUME /root/build_output
WORKDIR /root
COPY build.sh /root
CMD ["/bin/bash", "/root/build.sh"]
