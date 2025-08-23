FROM ubuntu:24.04

RUN apt update -y && \
    apt install -y \
    build-essential \
    cmake \
    automake \
    autoconf \
    pkg-config \
    libtool \
     && apt clean all

RUN apt update -y && \
    apt install -y \
      zlib1g-dev \
      libbz2-dev \
      libxml2-dev \
      libjpeg-dev \
      libpng-dev \
      libtiff-dev \
      libheif-dev \
     && apt clean all

RUN apt update -y && \
    apt install -y \
     bzip2 \
     curl \
    && apt clean all

ARG IMAGEMAGICK_VERSION=7.1.2-1

RUN curl -LO https://imagemagick.org/archive/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz && \
    tar xvfJ ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz && \
    cd ImageMagick-${IMAGEMAGICK_VERSION} && \
    ./configure --prefix=/usr/local --enable-shared && \
    make -j$(nproc) && \
    make install

RUN ldconfig

RUN magick -version && magick identify -list format

# Install Amazon Corretto 21 LTS
RUN curl https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | tee /etc/apt/sources.list.d/corretto.list && \
    apt update -y && \
    apt install -y java-21-amazon-corretto-jdk && \
    java -version

