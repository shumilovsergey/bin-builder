#!/usr/bin/env bash
set -euo pipefail

PUBLIC_REPO="https://github.com/shumilovsergey/bin-builder.git"
TMP_DIR="/tmp/shumilov-public-builds"

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "Not inside a git repository"
    exit 1
}

TARGET_DIR="$REPO_ROOT/shumilov_builds"

rm -rf "$TMP_DIR"

git clone --depth=1 "$PUBLIC_REPO" "$TMP_DIR"

if [ ! -d "$TMP_DIR/builds" ]; then
    echo "Error: no builds/ directory found in $PUBLIC_REPO"
    rm -rf "$TMP_DIR"
    exit 1
fi

rm -rf "$TARGET_DIR"
mkdir -p "$TARGET_DIR"

rsync -av "$TMP_DIR/builds/" "$TARGET_DIR/"
cp "$TMP_DIR/tools/RULES.md" "$TARGET_DIR/RULES.md"

rm -rf "$TMP_DIR"

echo "shumilov_builds synced"
