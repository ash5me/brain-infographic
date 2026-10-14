# Brain regions by creative activity

An interactive infographic. **Zig** compiles to WebAssembly and acts as the data
engine (activity x region table, overlap counts, ranking, explanatory text).
**Svelte 5** renders the brain and the controls.

```
zig/brain.zig            data engine, exported to wasm, with unit tests
web/src/lib/engine.js    loads brain.wasm and wraps its exports
web/src/lib/regions.js   SVG geometry for each region (order matches Zig)
web/src/Brain.svelte     brain illustration
web/src/App.svelte       activity picker, ranked region list
```

## Requirements

- Zig 0.14 or newer (the project was built and tested with 0.17.0)
- Node 20+

## Run it

```sh
./build.sh dev      # compile wasm, start Vite at http://localhost:5173
./build.sh          # compile wasm, production build in web/dist
./build.sh test     # Zig unit tests
```

```
cd brain-infographic\web
npm install
npm run dev
```

If your Zig binary isn't on `PATH` as `zig`, set it: `ZIG="python3 -m ziglang" ./build.sh`.

## Changing the data

Edit the `table` in `zig/brain.zig` (weights: 0 none, 1 supporting, 2 main).
Add a region by extending the `Region` enum and `region_n`, adding a column to
every row, and adding a matching entry to `REGIONS` in `regions.js`.
Add an activity the same way with `Activity`, `activity_n`, and `activities.js`.
