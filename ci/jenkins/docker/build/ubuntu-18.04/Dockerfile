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
    sudo \
    ninja-build

ARG USER_ID=1000
ARG GROUP_ID=1000


RUN groupadd -g $GROUP_ID user && \
    useradd -u $USER_ID -s /bin/sh -m -d /home/user -g user user && \
    usermod -aG sudo user && \
    echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
ENV CMAKE_GENERATOR=Ninja
ENV CPACK_GENERATOR=DEB
ENV PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
RUN git clone https://github.com/MediaArea/ZenLib.git /deps/ZenLib/source && \
    mkdir /deps/ZenLib/build && \
    cd /deps/ZenLib/build && \
    cmake -S /deps/ZenLib/source/Project/CMake -G Ninja && \
    cmake --build . --target install && \
    rm -rf /deps/ZenLib


RUN git clone https://github.com/MediaArea/MediaInfoLib.git /deps/MediaInfoLib/source && \
    mkdir /deps/MediaInfoLib/build && \
    cd /deps/MediaInfoLib/build && \
    cmake -S /deps/MediaInfoLib/source/Project/CMake -G Ninja && \
    cmake --build . --target install && \
    rm -rf /deps/MediaInfoLib

