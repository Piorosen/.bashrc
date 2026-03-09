#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[refresh] Installing python deps (numpy, pillow)"
python3 -m pip install --user numpy pillow >/dev/null

echo "[refresh] Ensuring executable bits"
chmod +x "$ROOT_DIR/.chacharc/bin/cinamol" "$ROOT_DIR/.chacharc/bin/saver"

if command -v ffmpeg >/dev/null 2>&1; then
  if ffmpeg -hide_banner -formats 2>/dev/null | grep -q " caca "; then
    echo "[refresh] ffmpeg+caca support: OK"
  else
    echo "[refresh] WARNING: ffmpeg is installed but caca format is missing."
    echo "[refresh] saver may not work until ffmpeg is built with libcaca support."
  fi
else
  echo "[refresh] WARNING: ffmpeg not found. saver requires ffmpeg."
fi

echo "[refresh] Done"
