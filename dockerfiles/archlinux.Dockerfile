FROM archlinux:latest
ENV OS_NAME=archlinux
RUN echo 'Server = https://mirrors.tuna.tsinghua.edu.cn/archlinux/$repo/os/$arch' >/etc/pacman.d/mirrorlist \
    && pacman -Syyu --noconfirm \
    && pacman -S --noconfirm gcc make cmake xorg
VOLUME /root/dandelion-dev
VOLUME /root/build_output
WORKDIR /root
COPY build.sh /root
CMD ["/bin/bash", "/root/build.sh"]
