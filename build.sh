#!/usr/bin/env bash
# Compile the Zig engines to WebAssembly, then build or serve the Svelte app.
#   ./build.sh          compile wasm + production build  -> web/dist
#   ./build.sh dev      compile wasm + Vite dev server
#   ./build.sh test     run the Zig unit tests
# If zig isn't on PATH:  ZIG="python3 -m ziglang" ./build.sh
set -euo pipefail
cd "$(dirname "$0")"

ZIG="${ZIG:-zig}"

compile() {
  # $1 = source name without extension (brain, gaps)
  $ZIG build-exe "zig/$1.zig" \
    -target wasm32-freestanding -O ReleaseSmall -fno-entry -rdynamic \
    -femit-bin="web/public/$1.wasm"
}

case "${1:-build}" in
  test)
    $ZIG test zig/brain.zig
    $ZIG test zig/gaps.zig
    ;;
  dev | build)
    compile brain
    compile gaps
    cd web
    [ -d node_modules ] || npm install
    if [ "${1:-build}" = dev ]; then npm run dev; else npm run build; fi
    ;;
  *)
    echo "usage: $0 [build|dev|test]" >&2
    exit 1
    ;;
esac
