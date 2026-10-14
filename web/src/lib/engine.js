// Thin wrapper around the Zig-compiled WebAssembly module (zig/brain.zig).

const ALL = 0xffffffff; // matches `all_activities` in brain.zig

export async function loadEngine() {
  const url = `${import.meta.env.BASE_URL}brain.wasm`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Could not load ${url} (${res.status})`);

  const { instance } = await WebAssembly.instantiate(await res.arrayBuffer());
  const x = instance.exports;
  const decoder = new TextDecoder();

  const activityCount = x.activity_count();
  const regionCount = x.region_count();

  return {
    ALL,
    activityCount,
    regionCount,

    /** 0 = not involved, 1 = supporting, 2 = main. */
    weight: (a, r) => x.weight(a, r),

    /** How many of the activities use region r. */
    overlap: (r) => x.overlap(r),

    /** Plain-language description of what region r does during activity a. */
    role(a, r) {
      const bytes = new Uint8Array(x.memory.buffer, x.role_ptr(a, r), x.role_len(a, r));
      return decoder.decode(bytes);
    },

    /** Region indices involved in activity a (or ALL), strongest first. */
    rank(a) {
      const n = x.rank(a >>> 0);
      return Array.from(new Uint8Array(x.memory.buffer, x.out_ptr(), n));
    },
  };
}
