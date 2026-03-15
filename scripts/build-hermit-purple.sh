#!/usr/bin/env bash
# build-hermit-purple.sh — Build ChefKiss QEMU Apple Silicon emulator on Intel x86
#
# Run this on the iMac Pro (after Tahoe update) or Beast (Linux).
# Produces: qemu-system-aarch64 capable of running VMApple + T8030 machines
# with TCG software emulation on x86_64 hosts.
#
# Usage:
#   bash scripts/build-hermit-purple.sh          # Full build
#   bash scripts/build-hermit-purple.sh --clean  # Clean + rebuild

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
QEMU_SRC="${REPO_ROOT}/../QEMUAppleSilicon"
BUILD_DIR="${QEMU_SRC}/build"
INSTALL_DIR="${HOME}/hermit-purple"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${GREEN}[HP]${NC} $*"; }
warn() { echo -e "${YELLOW}[HP]${NC} $*"; }
err()  { echo -e "${RED}[HP]${NC} $*" >&2; }

# ── Detect host platform ──────────────────────────────────────────

detect_platform() {
    local arch
    arch="$(uname -m)"
    local os
    os="$(uname -s)"

    log "Host: ${os} ${arch}"

    if [[ "$arch" != "x86_64" ]]; then
        warn "This script is designed for x86_64 hosts."
        warn "On Apple Silicon, use HVF directly — TCG is unnecessary."
    fi

    if [[ "$os" == "Darwin" ]]; then
        PLATFORM="macos"
        log "Platform: macOS (will use Homebrew for dependencies)"
    elif [[ "$os" == "Linux" ]]; then
        PLATFORM="linux"
        log "Platform: Linux (will use apt/dnf for dependencies)"
    else
        err "Unsupported platform: $os"
        exit 1
    fi
}

# ── Install dependencies ──────────────────────────────────────────

install_deps_macos() {
    log "Installing build dependencies via Homebrew..."
    brew install --quiet \
        ninja meson pkg-config glib pixman \
        libslirp sdl2 lzfse libtasn1 \
        python3 || true
    log "macOS dependencies installed"
}

install_deps_linux() {
    log "Installing build dependencies..."
    if command -v apt-get &>/dev/null; then
        sudo apt-get update -qq
        sudo apt-get install -y -qq \
            build-essential ninja-build meson pkg-config \
            libglib2.0-dev libpixman-1-dev libslirp-dev \
            libsdl2-dev liblzfse-dev libtasn1-6-dev \
            python3 python3-venv git flex bison \
            libcap-ng-dev libattr1-dev libfdt-dev
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y \
            gcc g++ ninja-build meson pkg-config \
            glib2-devel pixman-devel libslirp-devel \
            SDL2-devel libtasn1-devel \
            python3 git flex bison \
            libcap-ng-devel libattr-devel libfdt-devel
    else
        err "No supported package manager found (apt/dnf)"
        exit 1
    fi
    log "Linux dependencies installed"
}

install_deps() {
    if [[ "$PLATFORM" == "macos" ]]; then
        install_deps_macos
    else
        install_deps_linux
    fi
}

# ── Build QEMU ────────────────────────────────────────────────────

build_qemu() {
    if [[ ! -d "$QEMU_SRC" ]]; then
        err "ChefKiss QEMU source not found at: $QEMU_SRC"
        err "Clone it first:"
        err "  git clone https://github.com/ChefKissInc/QEMUAppleSilicon.git"
        exit 1
    fi

    cd "$QEMU_SRC"

    # Initialize submodules
    log "Initializing submodules..."
    git submodule update --init --recursive 2>/dev/null || true

    # Clean if requested
    if [[ "${1:-}" == "--clean" ]]; then
        log "Cleaning previous build..."
        rm -rf "$BUILD_DIR"
    fi

    # Configure
    if [[ ! -f "$BUILD_DIR/build.ninja" ]]; then
        log "Configuring QEMU build..."
        log "  Target: aarch64-softmmu (Apple Silicon emulation)"
        log "  Accelerator: TCG (software emulation for x86 hosts)"
        log "  Install prefix: $INSTALL_DIR"

        mkdir -p "$BUILD_DIR"
        cd "$BUILD_DIR"

        # Core configure — only build what we need
        "$QEMU_SRC/configure" \
            --target-list=aarch64-softmmu \
            --prefix="$INSTALL_DIR" \
            --enable-tcg \
            --enable-slirp \
            --enable-sdl \
            --disable-kvm \
            --disable-xen \
            --disable-docs \
            --disable-werror \
            --extra-cflags="-DCONFIG_APPLE_SOC=1"

        log "Configure complete"
    else
        log "Build already configured, reusing (use --clean to reconfigure)"
        cd "$BUILD_DIR"
    fi

    # Build
    local nproc
    nproc="$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)"
    log "Building with ${nproc} parallel jobs..."

    ninja -j"$nproc"

    log "Build complete!"
    log "Binary: ${BUILD_DIR}/qemu-system-aarch64"

    # Verify
    if [[ -x "${BUILD_DIR}/qemu-system-aarch64" ]]; then
        local version
        version="$("${BUILD_DIR}/qemu-system-aarch64" --version | head -1)"
        log "Verified: $version"

        # Check that T8030 and VMApple machines are available
        local machines
        machines="$("${BUILD_DIR}/qemu-system-aarch64" -machine help 2>/dev/null || true)"
        if echo "$machines" | grep -q "t8030"; then
            log "Machine 't8030' (iPhone 11 / A13): AVAILABLE"
        else
            warn "Machine 't8030' not found — Apple Silicon SoC support may not be compiled in"
        fi
        if echo "$machines" | grep -q "vmapple"; then
            log "Machine 'vmapple' (macOS VM): AVAILABLE"
        else
            warn "Machine 'vmapple' not found"
        fi
    else
        err "Build failed — qemu-system-aarch64 not found"
        exit 1
    fi
}

# ── Install ───────────────────────────────────────────────────────

install_qemu() {
    cd "$BUILD_DIR"
    log "Installing to ${INSTALL_DIR}..."
    ninja install
    log "Installed. Add to PATH:"
    log "  export PATH=\"${INSTALL_DIR}/bin:\$PATH\""
}

# ── Main ──────────────────────────────────────────────────────────

main() {
    echo ""
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  Project Hermit Purple — Apple Silicon on Intel x86     ║${NC}"
    echo -e "${CYAN}║  ChefKiss QEMU + VMApple + TCG                         ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""

    detect_platform
    install_deps
    build_qemu "${1:-}"
    install_qemu

    echo ""
    log "Build complete! Next steps:"
    log ""
    log "  1. Obtain macOS ARM restore image (IPSW):"
    log "     https://developer.apple.com/documentation/virtualization"
    log ""
    log "  2. Prepare disk images:"
    log "     qemu-img create -f qcow2 macos-arm.qcow2 64G"
    log ""
    log "  3. First boot attempt (VMApple path):"
    log "     ${INSTALL_DIR}/bin/qemu-system-aarch64 \\"
    log "       -M vmapple \\"
    log "       -cpu max \\"
    log "       -accel tcg,thread=multi \\"
    log "       -smp 4 \\"
    log "       -m 8G \\"
    log "       -drive file=macos-arm.qcow2,if=virtio \\"
    log "       -serial stdio \\"
    log "       -display sdl"
    log ""
    log "  4. If VMApple fails, try T8030 (ChefKiss iOS path):"
    log "     ${INSTALL_DIR}/bin/qemu-system-aarch64 \\"
    log "       -M t8030 \\"
    log "       -kernel kernelcache.release.iphone12 \\"
    log "       -dtb DeviceTree.iphone12 \\"
    log "       -serial stdio"
    echo ""
}

main "$@"
