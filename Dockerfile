# Dockerfile for building Whisperfish
# This container provides all dependencies needed to build the project
FROM golang:1.24-bookworm

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Set up Go environment variables
ENV GOPATH=/go
ENV PATH=$GOPATH/bin:$PATH

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
# Note: The tools will be available but need to be set up with qtsetup on first use
ENV GOQT_VERSION=c6ada02b904734c7f78a8032acd2e6fee3e58dba
RUN cd $GOPATH/src/github.com/therecipe && \
    git clone https://github.com/therecipe/qt && \
    cd qt && \
    git checkout $GOQT_VERSION
# Add Qt bindings to Go path so they can be imported
ENV GOPATH=$GOPATH:/go/src/github.com/therecipe/qt

# Set environment variables for Qt
ENV QT_VERSION=5.7.0
ENV QT_PKG_CONFIG=true
ENV QT_QMAKE_DIR=/usr/lib/qt5/bin

# Default command
CMD ["/bin/bash"]

# Build instructions:
# docker build -t whisperfish-build .
# docker run -it --rm -v $(pwd):/workspace whisperfish-build
