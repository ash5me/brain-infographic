#!/usr/bin/env bash
# Compile the Zig engine to WebAssembly, then build or serve the Svelte app.
#   ./build.sh          compile wasm + production build  -> web/dist
#   ./build.sh dev      compile wasm + Vite dev server
#   ./build.sh test     run the Zig unit tests
set -euo pipefail
cd "$(dirname "$0")"

ZIG="${ZIG:-zig}"

case "${1:-build}" in
  test)
    $ZIG test zig/brain.zig
    ;;
  dev | build)
    $ZIG build-exe zig/brain.zig \
      -target wasm32-freestanding -O ReleaseSmall -fno-entry -rdynamic \
      -femit-bin=web/public/brain.wasm
    cd web
    [ -d node_modules ] || npm install
    if [ "${1:-build}" = dev ]; then npm run dev; else npm run build; fi
    ;;
  *)
    echo "usage: $0 [build|dev|test]" >&2
    exit 1
    ;;
esac
