# Docker Build Environment for Whisperfish

This directory contains the Docker configuration for building Whisperfish with all required dependencies.

## Quick Start

### Building with Docker

```bash
# Build the Docker image
docker build -t whisperfish-build .

# Run tests
docker run --rm -v $(pwd):/workspace -w /workspace whisperfish-build go test -v ./store/...

# Build the project
docker run --rm -v $(pwd):/workspace -w /workspace whisperfish-build bash -c "
  QT_VERSION=5.7.0 qtmoc ./settings && \
  QT_VERSION=5.7.0 qtmoc ./model && \
  QT_VERSION=5.7.0 qtmoc ./worker && \
  go build -v .
"
```

### Using VS Code Dev Container

1. Install the [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
2. Open this project in VS Code
3. Press `F1` and select "Remote-Containers: Reopen in Container"
4. VS Code will build the container and open the project inside it

Once inside the container, you can:
- Run `go test ./store/...` to run tests
- Run `go build .` to build the project
- Use the integrated terminal with all dependencies available

## What's Included

The Docker container includes:

- **Go 1.24.12** - Latest Go toolchain
- **Qt 5.7.0** - Qt5 development libraries and tools
- **therecipe/qt** - Go bindings for Qt (version c6ada02b)
- **SQLCipher** - Encrypted database support
- **Build tools** - gcc, g++, make, pkg-config
- **Git** - Version control

## Container Structure

```
/workspace         - Your project directory (mounted)
/go                - Go workspace (GOPATH)
/usr/local/go      - Go installation (GOROOT)
/go/src/github.com/therecipe/qt - Qt Go bindings
```

## Environment Variables

- `GOROOT=/usr/local/go`
- `GOPATH=/go`
- `QT_VERSION=5.7.0`
- `QT_PKG_CONFIG=true`
- `GOQT_VERSION=c6ada02b904734c7f78a8032acd2e6fee3e58dba`

## Building Qt Bindings

The container automatically installs the Qt bindings at the specific version required by Whisperfish. To generate the moc files:

```bash
docker run --rm -v $(pwd):/workspace -w /workspace whisperfish-build bash -c "
  QT_VERSION=5.7.0 qtmoc ./settings
  QT_VERSION=5.7.0 qtmoc ./model
  QT_VERSION=5.7.0 qtmoc ./worker
"
```

## CI/CD Integration

A GitHub Actions workflow is provided in `.github/workflows/build.yml` that:
1. Builds the Docker image
2. Runs tests
3. Generates Qt bindings
4. Verifies the full build

## Troubleshooting

### Qt bindings compilation errors

If you see errors like `ConnectStringSet undefined`, you need to regenerate the moc files:

```bash
docker run --rm -v $(pwd):/workspace -w /workspace whisperfish-build bash -c "
  QT_VERSION=5.7.0 qtmoc ./settings && \
  QT_VERSION=5.7.0 qtmoc ./model && \
  QT_VERSION=5.7.0 qtmoc ./worker
"
```

### Permission issues

If you encounter permission issues with files created by the container, you can run with your user ID:

```bash
docker run --rm -u $(id -u):$(id -g) -v $(pwd):/workspace -w /workspace whisperfish-build go build .
```

### Building for different architectures

The container is configured for amd64 by default. For cross-compilation, you'll need to set up additional toolchains.

## Differences from Sailfish SDK

This Docker environment is designed for:
- **Development** - Quick iteration and testing
- **CI/CD** - Automated builds and tests
- **Code editing** - Working with the codebase

For building actual Sailfish OS packages (RPM files), you still need the full Sailfish OS SDK as described in the main README.rst.

## Notes

- The container includes Qt 5.7.0 libraries, matching the version specified in `build.sh`
- Go modules are used for dependency management (no glide required)
- The therecipe/qt bindings are installed at commit c6ada02b as specified in `build.sh`
- SQLCipher is included for encrypted database support
