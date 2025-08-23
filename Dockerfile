# --- Stage 1: Build ImageMagick ---
FROM ubuntu:24.04 AS builder

# Install build tools and development libraries
RUN apt update -y && \
    apt install -y \
    build-essential \
    cmake \
    automake \
    autoconf \
    pkg-config \
    libtool \
    zlib1g-dev \
    libbz2-dev \
    libxml2-dev \
    libjpeg-dev \
    libpng-dev \
    libtiff-dev \
    libheif-dev \
    bzip2 \
    curl \
    && apt-get clean all

# Build and install ImageMagick
ARG IMAGEMAGICK_VERSION=7.1.2-1
RUN curl -LO https://imagemagick.org/archive/releases/ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz && \
    tar xvfJ ImageMagick-${IMAGEMAGICK_VERSION}.tar.xz && \
    cd ImageMagick-${IMAGEMAGICK_VERSION} && \
    ./configure --prefix=/usr/local --enable-shared && \
    make -j$(nproc) && \
    make install

# --- Stage 2: Final Runtime Image ---
FROM ubuntu:24.04

# Install only the runtime dependencies for ImageMagick and Java
RUN apt update -y && \
    apt install -y \
    zlib1g \
    libbz2-1.0 \
    libxml2 \
    libjpeg-turbo8 \
    libpng16-16 \
    libtiff6 \
    libheif1 \
    libwebpdemux2 \
    libwebpmux3 \
    libwebp-dev \
    libgomp1 \
    && apt-get clean all

# Copy the built ImageMagick binaries from the builder stage
COPY --from=builder /usr/local/bin/ /usr/local/bin/
COPY --from=builder /usr/local/lib/ /usr/local/lib/
COPY --from=builder /usr/local/include/ /usr/local/include/
COPY --from=builder /usr/local/share/ /usr/local/share/

# Install Amazon Corretto 21 LTS
RUN apt update -y && \
    apt install -y curl gnupg && \
    curl https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" | tee /etc/apt/sources.list.d/corretto.list && \
    apt update -y && \
    apt install -y java-21-amazon-corretto-jdk && \
    apt remove -y curl gnupg && \
    apt clean all \

# Validate installations
RUN ldconfig && \
    magick -version && \
    java -version