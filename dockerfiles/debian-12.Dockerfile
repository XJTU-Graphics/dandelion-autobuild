FROM debian:12
ARG use_mirror
ENV OS_NAME=debian-12

RUN if [ "$use_mirror" = "true" ]; then \
    sed -i 's#deb.debian.org#mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list.d/debian.sources; \
    fi; \
    apt-get update \
    && apt-get install -y build-essential cmake libwayland-dev libxkbcommon-dev xorg-dev
VOLUME /root/dandelion-dev
VOLUME /root/build_output
WORKDIR /root
COPY build.sh /root
CMD ["/bin/bash", "/root/build.sh"]
