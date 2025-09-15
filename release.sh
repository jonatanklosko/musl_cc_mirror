#!/bin/bash

set -euo pipefail

ARTIFACTS=(
  "x86_64-linux-musl-cross.tgz"
  "aarch64-linux-musl-cross.tgz"
  "riscv64-linux-musl-cross.tgz"
)

BASE_URL="https://musl.cc"

RELEASE_NAME=$(date -u +"%Y%m%d_%H%M%S")

DOWNLOAD_DIR="tmp/$RELEASE_NAME"

echo "Starting release process for: $RELEASE_NAME"

mkdir -p "$DOWNLOAD_DIR"

echo "Downloading artifacts to $DOWNLOAD_DIR/..."
for artifact in "${ARTIFACTS[@]}"; do
  echo "Downloading $artifact..."
  wget "$BASE_URL/$artifact" -O "$DOWNLOAD_DIR/$artifact"

  echo "✓ Downloaded $artifact ($(du -h "$DOWNLOAD_DIR/$artifact" | cut -f1))"
done

echo "All artifacts downloaded successfully!"

if ! command -v gh &> /dev/null; then
  echo "Error: GitHub CLI (gh) is not installed. Please install it to create releases."
  echo "You can install it from: https://cli.github.com/"
  exit 1
fi

cd "$DOWNLOAD_DIR"
gh release create "$RELEASE_NAME" \
  --title "Release $RELEASE_NAME" \
  --notes "Artifacts sourced from https://musl.cc - $(date -u)" \
  --latest \
  "${ARTIFACTS[@]}"

echo "Release created successfully: $RELEASE_NAME"
echo "View it at: $(gh repo view --web | grep -o 'https://[^[:space:]]*')/releases/tag/$RELEASE_NAME"

rm -rf "$DOWNLOAD_DIR"
echo "✓ Cleaned up $DOWNLOAD_DIR"

echo "Done!"
