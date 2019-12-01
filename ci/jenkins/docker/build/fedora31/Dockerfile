FROM fedora:31

RUN dnf update -y && \
    dnf group install "C Development Tools and Libraries" -y && \
    dnf install -y cmake git zlib-devel libcurl-devel

ARG USER_ID=1000
ARG GROUP_ID=1000

RUN groupadd -g $GROUP_ID user && \
    useradd -u $USER_ID -s /bin/sh -m -d /home/user -g user user

ENV PATH="/home/user/local/bin:${PATH}"
