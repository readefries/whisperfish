# Docker Build Environment for Whisperfish

This directory contains the Docker configuration for building Whisperfish with all required dependencies.

## Quick Start

### Building with Docker

```bash
# Build the Docker image
docker build -t whisperfish-build .

# Run tests (working!)
docker run --rm -v $(pwd):/workspace -w /workspace whisperfish-build bash -c "go mod tidy && go test -v ./store/..."

# Build non-Qt packages (working!)
docker run --rm -v $(pwd):/workspace -w /workspace whisperfish-build go build -v ./store/...
```

**Note:** Full application build with Qt bindings requires additional setup (see Limitations section below).

### Using VS Code Dev Container

1. Install the [Remote - Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) extension
2. Open this project in VS Code
3. Press `F1` and select "Remote-Containers: Reopen in Container"
4. VS Code will build the container and open the project inside it

Once inside the container, you can:
- Run `go test ./store/...` to run tests
- Work with the Go codebase
- Use the integrated terminal with all dependencies available

## What's Included

The Docker container includes:

- **Go 1.24** - Latest Go toolchain compatible with dependencies
- **Qt 5.15** - Qt5 development libraries and tools from Debian repos
- **therecipe/qt source** - Go bindings for Qt (cloned but not built)
- **SQLCipher** - Encrypted database support
- **Build tools** - gcc, g++, make, pkg-config
- **Git** - Version control

## Container Structure

```
/workspace         - Your project directory (mounted)
/go                - Go workspace (GOPATH)
/usr/local/go      - Go installation (GOROOT)
/go/src/github.com/therecipe/qt - Qt Go bindings source
```

## Environment Variables

- `GOPATH=/go`
- `QT_VERSION=5.7.0` (target version)
- `QT_PKG_CONFIG=true`
- `GOQT_VERSION=c6ada02b904734c7f78a8032acd2e6fee3e58dba` (therecipe/qt commit)

## What Works

✅ **Store package tests** - All 8 tests pass
✅ **Core Go packages** - Can build store, model packages
✅ **Dependency management** - Go modules work correctly
✅ **Development environment** - VS Code devcontainer ready

## Limitations

⚠️ **Qt bindings compilation** - The therecipe/qt library is very old (2020) and was designed for Go 1.13-1.16 with GO111MODULE support. Modern Go (1.24+) has removed support for GO111MODULE=off, making it difficult to build the Qt binding tools (qtmoc, qtminimal, qtsetup) in the container.

**Workarounds:**
1. **For testing**: Use the Docker container to run store tests and work with non-Qt code
2. **For Qt development**: Use the traditional Sailfish OS SDK as described in README.rst
3. **Alternative**: The Qt bindings source is available at `/go/src/github.com/therecipe/qt` if you want to attempt manual setup

## CI/CD Integration

A GitHub Actions workflow is provided in `.github/workflows/build.yml` that:
1. Builds the Docker image
2. Runs store package tests ✅
3. Verifies non-Qt packages compile ✅

Qt binding generation is not included in the automated workflow due to the limitations above.

## Troubleshooting

### Permission issues

If you encounter permission issues with files created by the container:

```bash
docker run --rm -u $(id -u):$(id -g) -v $(pwd):/workspace -w /workspace whisperfish-build go test ./store/...
```

### Qt bindings

The container includes Qt libraries but not the working qtmoc tool due to compatibility issues with modern Go. For full Qt binding generation, use the Sailfish OS SDK.

## Differences from Sailfish SDK

This Docker environment is designed for:
- **Development** - Working with Go code and tests ✅
- **CI/CD** - Automated testing of core packages ✅
- **Code editing** - Development without heavy SDK installation ✅

For building actual Sailfish OS packages (RPM files) with Qt UI, you still need the full Sailfish OS SDK as described in the main README.rst.

## Notes

- The container uses Qt 5.15 from Debian (not 5.7.0 as originally specified in build.sh)
- Go modules are used for dependency management
- The therecipe/qt bindings source is available but tools are not built
- SQLCipher is included for encrypted database support
- All store tests pass successfully in the container
