# Dockerfile for building Whisperfish
# This container provides all dependencies needed to build the project
FROM ubuntu:22.04

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set up Go version
ENV GO_VERSION=1.24.12
ENV GOROOT=/usr/local/go
ENV GOPATH=/go
ENV PATH=$GOROOT/bin:$GOPATH/bin:$PATH

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # Build essentials
    build-essential \
    gcc \
    g++ \
    make \
    git \
    wget \
    curl \
    pkg-config \
    # Qt5 development libraries
    qt5-qmake \
    qtbase5-dev \
    qtbase5-dev-tools \
    qtdeclarative5-dev \
    qtquickcontrols2-5-dev \
    libqt5quick5 \
    libqt5qml5 \
    libqt5core5a \
    libqt5gui5 \
    libqt5network5 \
    libqt5widgets5 \
    # SQLCipher and SQLite dependencies
    libsqlcipher-dev \
    libsqlite3-dev \
    # OpenSSL for crypto operations
    libssl-dev \
    # Additional dependencies
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Install Go
RUN wget https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm go${GO_VERSION}.linux-amd64.tar.gz

# Set up Go workspace
RUN mkdir -p $GOPATH/src $GOPATH/bin $GOPATH/pkg
WORKDIR $GOPATH/src

# Pre-install therecipe/qt bindings tools
# Note: The specific version will be installed when building the project
RUN mkdir -p $GOPATH/src/github.com/therecipe

# Set up working directory
WORKDIR /workspace

# Copy go module files first for better caching
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the project
COPY . .

# Install therecipe/qt bindings at the specific version required by the project
ENV GOQT_VERSION=c6ada02b904734c7f78a8032acd2e6fee3e58dba
RUN cd $GOPATH/src/github.com/therecipe && \
    git clone https://github.com/therecipe/qt && \
    cd qt && \
    git checkout $GOQT_VERSION && \
    cd cmd/qtsetup && go install . && \
    cd ../qtmoc && go install . && \
    cd ../qtminimal && go install .

# Set environment variables for Qt
ENV QT_VERSION=5.7.0
ENV QT_PKG_CONFIG=true
ENV QT_QMAKE_DIR=/usr/lib/qt5/bin

# Default command
CMD ["/bin/bash"]

# Build instructions:
# docker build -t whisperfish-build .
# docker run -it --rm -v $(pwd):/workspace whisperfish-build
