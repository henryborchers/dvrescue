FROM ubuntu:18.04

RUN apt-get update -y && \
    apt-get install -y \
    cmake \
    git \
    libtool \
    automake \
    zlib1g-dev \
    pkg-config \
    libcurl4-gnutls-dev \
    build-essential \
    sudo

ARG USER_ID=1000
ARG GROUP_ID=1000


RUN groupadd -g $GROUP_ID user && \
    useradd -u $USER_ID -s /bin/sh -m -d /home/user -g user user && \
    usermod -aG sudo user && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV CPACK_GENERATOR=DEB