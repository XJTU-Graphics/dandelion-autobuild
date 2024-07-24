FROM ubuntu:24.04
ARG use_mirror
ENV OS_NAME=ubuntu-24.04

RUN if [ "$use_mirror" = "true" ]; then \
    sed -i 's#archive.ubuntu.com#mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list.d/ubuntu.sources; \
    fi; \
    cat /etc/apt/sources.list; \
    apt-get update \
    && apt-get install -y build-essential cmake libwayland-dev libxkbcommon-dev xorg-dev
VOLUME /root/dandelion-dev
VOLUME /root/build_output
WORKDIR /root
COPY build.sh /root
CMD ["/bin/bash", "/root/build.sh"]
