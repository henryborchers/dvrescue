FROM centos:7
RUN yum -y update && \
    yum groupinstall -y "Development Tools" && \
    yum install -y epel-release && \
    yum install -y \
    cmake3 \
    git \
    zlib-devel \
    libcurl-devel \
    sudo \
    rpmdevtools \
    ninja-build

#RUN alternatives --install /usr/local/bin/cmake cmake /usr/bin/cmake 10 \
#    --slave /usr/local/bin/ctest ctest /usr/bin/ctest \
#    --slave /usr/local/bin/cpack cpack /usr/bin/cpack \
#    --slave /usr/local/bin/ccmake ccmake /usr/bin/ccmake \
#    --family cmake

RUN alternatives --install /usr/bin/cmake cmake /usr/bin/cmake3 20 \
    --slave /usr/bin/ctest ctest /usr/bin/ctest3 \
    --slave /usr/bin/cpack cpack /usr/bin/cpack3 \
    --slave /usr/bin/ccmake ccmake /usr/bin/ccmake3 \
    --family cmake

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
