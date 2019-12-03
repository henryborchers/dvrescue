FROM ubuntu:16.04


RUN apt-get update -y && \
    apt-get install -y \
    apt-transport-https ca-certificates gnupg software-properties-common wget build-essential sudo

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -

RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ xenial main' && \
    apt-get update -y

RUN apt-get install -y cmake \
    git \
    libtool \
    automake \
    pkg-config \
    libcurl4-gnutls-dev \
    zlib1g-dev \
    ninja-build


ARG USER_ID=1000
ARG GROUP_ID=1000
RUN groupadd -g $GROUP_ID user && \
    useradd -u $USER_ID -s /bin/sh -m -d /home/user -g user user && \
    usermod -aG sudo user && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV CMAKE_GENERATOR=Ninja
ENV CPACK_GENERATOR=DEB

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
