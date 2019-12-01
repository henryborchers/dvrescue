FROM fedora:31

RUN dnf update -y && \
    dnf group install "C Development Tools and Libraries" -y && \
    dnf install -y cmake git zlib-devel libcurl-devel sudo

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g $GROUP_ID user && \
    useradd -u $USER_ID -s /bin/sh -m -d /home/user -g user user && \
    usermod -aG wheel user && \
    echo 'user ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

