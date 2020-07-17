
ARG USER_ID
ARG GROUP_ID
RUN groupadd -g $GROUP_ID docker_usr
RUN useradd -d /home/docker_usr -m -g $GROUP_ID -u $USER_ID -s /bin/bash docker_usr
RUN yum install -y epel-release
RUN yum install -y autoconf gperf bison flex texinfo help2man gcc-c++ libtool libtool-bin patch \
    ncurses-devel python34-devel perl-Thread-Queue bzip2 git wget xz unzip
RUN wget -O /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64
RUN chmod a+x /sbin/dumb-init
RUN echo 'export PATH=/opt/ctng/bin:$PATH' >> /etc/profile
# The limits in this file prevent su'ing to docker_usr user
RUN rm -f /etc/security/limits.d/90-nproc.conf
ENTRYPOINT [ "/sbin/dumb-init", "--" ]
