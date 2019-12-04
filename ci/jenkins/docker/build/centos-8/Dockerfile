FROM centos:8
RUN yum -y update && \
    yum groupinstall -y "Development Tools" && \
    yum install -y epel-release && \
    yum install -y \
        cmake \
        git \
        zlib-devel \
        libcurl-devel \
        sudo \
        rpmdevtools && \
    yum install -y ninja-build --enablerepo=PowerTools


ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g $GROUP_ID user && \
    useradd -u $USER_ID -s /bin/sh -m -d /home/user -g user user && \
    usermod -aG wheel user && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV CPACK_GENERATOR=RPM
ENV CMAKE_GENERATOR=Ninja