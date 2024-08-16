FROM archlinux:latest
ARG use_mirror
ENV OS_NAME=archlinux

RUN if [ "$use_mirror" = "true" ]; then \
    echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist; \
    fi; \
    pacman -Syyu --noconfirm \
    && pacman -S --noconfirm gcc make cmake xorg
VOLUME /root/dandelion
VOLUME /root/build_output
WORKDIR /root
COPY build.sh /root
ENTRYPOINT ["/bin/bash", "/root/build.sh"]
