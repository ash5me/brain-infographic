# Brain regions by creative activity

An interactive infographic. **Zig** compiles to WebAssembly and acts as the data
engine (activity x region table, overlap counts, ranking, explanatory text).
**Svelte 5** renders the brain and the controls.

```
zig/brain.zig            page 1 data: activities x regions, overlap, ranking
zig/gaps.zig            page 2 data: missing areas, their activities, tick state
web/src/lib/engine.js    loads brain.wasm and wraps its exports
web/src/lib/gaps.js      loads gaps.wasm and wraps its exports
web/src/lib/regions.js   page 1 SVG geometry (order matches brain.zig)
web/src/lib/areas.js     page 2 SVG geometry, outer and inner views (order matches gaps.zig)
web/src/App.svelte       hash router (#/ and #/gaps)
web/src/Nav.svelte       navigation bar
web/src/Activities.svelte + Brain.svelte   page 1
web/src/Gaps.svelte + BrainMap.svelte      page 2
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

If your Zig binary isn't on `PATH` as `zig`, set it: `ZIG="python3 -m ziglang" ./build.sh`.

## Pages

- `#/` Creative activities: which regions five activities use.
- `#/gaps` Missing areas: nine areas those activities skip, shown on an outer and an
  inner view of the brain, with tickable activities. Ticks are counted in Zig and
  saved to `localStorage`.

## Changing the data

Page 2: edit `areas` in `zig/gaps.zig` and the matching shapes in `web/src/lib/areas.js`.

Page 1:

Edit the `table` in `zig/brain.zig` (weights: 0 none, 1 supporting, 2 main).
Add a region by extending the `Region` enum and `region_n`, adding a column to
every row, and adding a matching entry to `REGIONS` in `regions.js`.
Add an activity the same way with `Activity`, `activity_n`, and `activities.js`.
