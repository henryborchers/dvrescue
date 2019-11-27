FROM ubuntu:16.04


RUN apt-get update -y && \
    apt-get install -y \
    apt-transport-https ca-certificates gnupg software-properties-common wget build-essential

RUN wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | apt-key add -

RUN apt-add-repository 'deb https://apt.kitware.com/ubuntu/ xenial main' && \
    apt-get update -y

RUN apt-get install -y cmake git libtool automake
