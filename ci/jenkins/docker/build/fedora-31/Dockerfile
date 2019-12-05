FROM fedora:31

RUN dnf update -y && \
    dnf group install "C Development Tools and Libraries" -y && \
    dnf install -y \
        cmake \
        git \
        zlib-devel \
        libcurl-devel \
        sudo \
        rpmdevtools \
        ninja-build

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g $GROUP_ID user && \
    useradd -u $USER_ID -s /bin/sh -m -d /home/user -g user user && \
    usermod -aG wheel user && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

ENV CPACK_GENERATOR=RPM
ENV CMAKE_GENERATOR=Ninja

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
