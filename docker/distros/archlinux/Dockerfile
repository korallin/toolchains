FROM archlinux/base:latest
ARG USER_ID
ARG GROUP_ID
RUN pacman -Sy --noconfirm archlinux-keyring
RUN pacman -Syu --noconfirm
RUN pacman -S --noconfirm base-devel git help2man python unzip wget audit
RUN groupadd -g $GROUP_ID docker_usr
RUN useradd -d /home/docker_usr -m -g $GROUP_ID -u $USER_ID -s /bin/bash docker_usr
RUN wget -O /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64
RUN chmod a+x /sbin/dumb-init
RUN echo 'export PATH=/opt/ctng/bin:$PATH' >> /etc/profile
RUN echo 'export MENUCONFIG_COLOR=mono' >> /etc/profile
ENTRYPOINT [ "/sbin/dumb-init", "--" ]
