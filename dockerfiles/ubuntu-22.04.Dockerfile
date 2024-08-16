FROM ubuntu:22.04
ARG use_mirror
ENV OS_NAME=ubuntu-22.04

RUN if [ "$use_mirror" = "true" ]; then \
    sed -i 's#archive.ubuntu.com#mirrors.tuna.tsinghua.edu.cn#g' /etc/apt/sources.list; \
    fi; \
    apt-get update \
    && apt-get install -y build-essential cmake libwayland-dev libxkbcommon-dev xorg-dev
VOLUME /root/dandelion
VOLUME /root/build_output
WORKDIR /root
COPY build.sh /root
ENTRYPOINT ["/bin/bash", "/root/build.sh"]
