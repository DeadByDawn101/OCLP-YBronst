#!/usr/bin/env bash
# Big Mouth Strikes Again — arch-aware build script
set -euo pipefail

ARCH=$(uname -m)
[[ "$ARCH" == "arm64" ]] && TARGET_ARCH="arm64" || TARGET_ARCH="x86_64"

echo "🖤 Building Big Mouth Strikes Again for $TARGET_ARCH"

# Fix typing package conflict
pip3 uninstall typing -y 2>/dev/null || true

# Update spec for this arch
sed -i '' "s/target_arch=\"[^\"]*\"/target_arch=\"$TARGET_ARCH\"/" OpenCore-Patcher-GUI.spec
echo "Target arch set: $TARGET_ARCH"

python3 -m PyInstaller ./OpenCore-Patcher-GUI.spec --noconfirm
echo "✅ Build complete: dist/OpenCore-Patcher.app"
