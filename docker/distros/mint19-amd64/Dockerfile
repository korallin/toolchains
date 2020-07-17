FROM linuxmintd/mint19-amd64
ARG USER_ID
ARG GROUP_ID
RUN groupadd -g $GROUP_ID docker_usr
RUN useradd -d /home/docker_usr -m -g $GROUP_ID -u $USER_ID -s /bin/bash docker_usr
RUN apt-get update
RUN apt-get install -y gcc gperf bison flex texinfo help2man make libncurses5-dev \
    python3-dev autoconf automake libtool libtool-bin gawk wget
RUN wget -O /sbin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.1/dumb-init_1.2.1_amd64
RUN chmod a+x /sbin/dumb-init
RUN echo 'export PATH=/opt/ctng/bin:$PATH' >> /etc/profile
ENTRYPOINT [ "/sbin/dumb-init", "--" ]
