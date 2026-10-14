// Thin wrapper around the Zig-compiled WebAssembly module (zig/gaps.zig).

export async function loadGaps() {
  const url = `${import.meta.env.BASE_URL}gaps.wasm`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Could not load ${url} (${res.status})`);

  const { instance } = await WebAssembly.instantiate(await res.arrayBuffer());
  const x = instance.exports;
  const decoder = new TextDecoder();
  const text = (ptr, len) => decoder.decode(new Uint8Array(x.memory.buffer, ptr, len));

  return {
    areaCount: x.area_count(),
    name: (a) => text(x.name_ptr(a), x.name_len(a)),
    what: (a) => text(x.what_ptr(a), x.what_len(a)),
    actCount: (a) => x.act_count(a),
    act: (a, i) => text(x.act_ptr(a, i), x.act_len(a, i)),
    setDone: (a, i, v) => x.set_done(a, i, v ? 1 : 0),
    isDone: (a, i) => x.is_done(a, i) === 1,
    doneCount: (a) => x.done_count(a),
    coveredCount: () => x.covered_count(),
    reset: () => x.reset(),
  };
}
