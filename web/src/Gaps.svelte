<script>
  import { onMount } from 'svelte';
  import BrainMap from './BrainMap.svelte';
  import { loadGaps } from './lib/gaps.js';
  import { AREAS } from './lib/areas.js';

  const OVERVIEW = -1;
  const STORE = 'brain-map-done-v1';

  let g = $state(null);
  let error = $state('');
  let selected = $state(OVERVIEW);
  let hovered = $state(null);
  let version = $state(0); // bumped whenever Zig's tick state changes

  onMount(async () => {
    try {
      g = await loadGaps();
      restore();
    } catch (e) {
      error = e.message;
    }
  });

  function restore() {
    try {
      const saved = JSON.parse(localStorage.getItem(STORE) ?? '[]');
      for (const [a, i] of saved) g.setDone(a, i, true);
      version++;
    } catch {
      /* storage unavailable or corrupt: start empty */
    }
  }

  function save() {
    try {
      const out = [];
      for (let a = 0; a < g.areaCount; a++)
        for (let i = 0; i < g.actCount(a); i++) if (g.isDone(a, i)) out.push([a, i]);
      localStorage.setItem(STORE, JSON.stringify(out));
    } catch {
      /* ignore */
    }
  }

  function toggle(a, i, on) {
    g.setDone(a, i, on);
    version++;
    save();
  }

  function reset() {
    g.reset();
    version++;
    save();
  }

  // Reading `version` makes these re-run after every change made in Zig.
  const done = (a, i) => (version, g.isDone(a, i));
  const doneN = (a) => (version, g.doneCount(a));
  const progress = (a) => (version, g.doneCount(a) / g.actCount(a));

  const covered = $derived(g ? (version, g.coveredCount()) : 0);

  const levels = $derived(
    g
      ? AREAS.map((_, a) => {
          if (selected === OVERVIEW) {
            const p = progress(a);
            return p > 0 ? 0.2 + 0.45 * p : 0;
          }
          return a === selected ? 0.62 : 0;
        })
      : [],
  );

  const labelled = $derived(
    [selected, hovered].filter((v, k, arr) => v !== null && v !== OVERVIEW && arr.indexOf(v) === k),
  );

  function nextSuggestion(a) {
    for (let i = 0; i < g.actCount(a); i++) if (!done(a, i)) return g.act(a, i);
    return null;
  }
</script>

<main>
  <header>
    <h1>The brain areas your activities miss</h1>
    <p>
      Writing, coding, design, drawing, and music leave these nine areas mostly idle. Pick one to see where
      it sits, then tick the activities you already do to track your coverage.
    </p>
  </header>

  {#if error}
    <p class="notice" role="alert">
      Couldn't load the data engine. {error}. Run <code>./build.sh</code> to compile it, then reload.
    </p>
  {:else if !g}
    <p class="notice" aria-live="polite">Loading…</p>
  {:else}
    <div class="layout">
      <fieldset class="picker">
        <legend class="sr">Brain area</legend>

        <label class:checked={selected === OVERVIEW}>
          <input type="radio" name="area" value={OVERVIEW} bind:group={selected} />
          <span class="name">Your coverage</span>
          <span class="count">{covered} of {g.areaCount} areas reached</span>
        </label>

        {#each AREAS as _, a}
          <label class:checked={selected === a}>
            <input type="radio" name="area" value={a} bind:group={selected} />
            <span class="name">{g.name(a)}</span>
            <span class="count">
              {doneN(a) > 0 ? `${doneN(a)} of ${g.actCount(a)} activities ticked` : g.what(a)}
            </span>
          </label>
        {/each}
      </fieldset>

      <section class="stage" aria-live="polite">
        <figure>
          <figcaption>Outer surface</figcaption>
          <BrainMap view="lateral" {levels} {labelled} {hovered} onhover={(i) => (hovered = i)} />
        </figure>
        <figure>
          <figcaption>Inner surface, cut down the middle</figcaption>
          <BrainMap view="medial" {levels} {labelled} {hovered} onhover={(i) => (hovered = i)} />
        </figure>
        <p class="key">
          The front of the brain is on the left. Dotted outlines are deep structures drawn as if the
          surface were see-through. Positions are approximate.
        </p>

        <div class="detail">
          {#if selected === OVERVIEW}
            <div class="detail-head">
              <h2>{covered} of {g.areaCount} areas reached</h2>
              <button type="button" onclick={reset}>Clear ticks</button>
            </div>
            <ul class="overview">
              {#each AREAS as _, a}
                {@const next = nextSuggestion(a)}
                <li
                  class:hot={hovered === a}
                  onpointerenter={() => (hovered = a)}
                  onpointerleave={() => (hovered = null)}
                >
                  <span class="bar" aria-hidden="true"><i style:width="{progress(a) * 100}%"></i></span>
                  <button type="button" class="link" onclick={() => (selected = a)}>{g.name(a)}</button>
                  <span class="hint">
                    {#if next}Try: {next}{:else}All activities ticked{/if}
                  </span>
                </li>
              {/each}
            </ul>
          {:else}
            <h2>{g.name(selected)}</h2>
            <p class="what">{g.what(selected)}</p>
            <ul class="acts">
              {#each { length: g.actCount(selected) } as _, i}
                <li>
                  <label>
                    <input
                      type="checkbox"
                      checked={done(selected, i)}
                      onchange={(e) => toggle(selected, i, e.currentTarget.checked)}
                    />
                    <span>{g.act(selected, i)}</span>
                  </label>
                </li>
              {/each}
            </ul>
            <p class="key">Tick what you already do. Your ticks stay in this browser.</p>
          {/if}
        </div>
      </section>
    </div>
  {/if}
</main>

<style>
  main {
    max-width: 68rem;
    margin: 0 auto;
    padding: clamp(1.5rem, 4vw, 3.5rem) clamp(1rem, 4vw, 2.5rem) 3rem;
  }
  header {
    margin-bottom: clamp(1.5rem, 4vw, 2.75rem);
  }
  h1 {
    font: 800 clamp(2.1rem, 5.5vw, 3.9rem) / 1.02 var(--display);
    letter-spacing: -0.025em;
    max-width: 16ch;
    margin: 0 0 1rem;
  }
  header p {
    max-width: 52ch;
    margin: 0;
    color: var(--muted);
    font-size: 1.125rem;
    line-height: 1.55;
  }
  .notice {
    color: var(--muted);
  }

  .layout {
    display: grid;
    grid-template-columns: minmax(15rem, 19rem) minmax(0, 1fr);
    gap: clamp(1.5rem, 4vw, 3rem);
    align-items: start;
  }

  /* ---- picker ---- */
  .picker {
    border: 0;
    margin: 0;
    padding: 0;
    display: flex;
    flex-direction: column;
    gap: 2px;
  }
  .picker label {
    position: relative;
    display: flex;
    flex-direction: column;
    padding: 0.7rem 0.9rem;
    cursor: pointer;
    border-radius: 6px;
    border: 1px solid transparent;
    border-left: 4px solid transparent;
  }
  .picker label:hover {
    background: var(--panel);
  }
  .picker label.checked {
    background: var(--panel);
    border-color: var(--line);
    border-left-color: var(--teal);
  }
  .picker input {
    position: absolute;
    opacity: 0;
    inset: 0;
    cursor: pointer;
  }
  .picker label:has(input:focus-visible) {
    outline: 2px solid var(--ink);
    outline-offset: 2px;
  }
  .name {
    font: 600 1.05rem / 1.25 var(--display);
  }
  .count {
    font-size: 0.85rem;
    color: var(--muted);
  }

  /* ---- stage ---- */
  .stage {
    background: var(--panel);
    border: 1px solid var(--line);
    border-radius: 10px;
    padding: clamp(0.75rem, 2vw, 1.5rem);
  }
  figure {
    margin: 0 0 0.5rem;
  }
  figcaption {
    font: 600 0.9rem var(--display);
    color: var(--muted);
    margin-bottom: 0.25rem;
  }
  .key {
    margin: 0.5rem 0 0;
    font-size: 0.8125rem;
    color: var(--muted);
  }

  .detail {
    margin-top: 1.25rem;
    padding-top: 1.25rem;
    border-top: 1px solid var(--line);
  }
  .detail-head {
    display: flex;
    align-items: center;
    justify-content: space-between;
    gap: 1rem;
  }
  h2 {
    font: 800 1.5rem / 1.15 var(--display);
    letter-spacing: -0.01em;
    margin: 0 0 0.25rem;
  }
  .what {
    margin: 0 0 0.75rem;
    color: var(--muted);
  }

  .acts {
    list-style: none;
    margin: 0;
    padding: 0;
  }
  .acts label {
    display: flex;
    align-items: center;
    gap: 0.7rem;
    padding: 0.5rem 0;
    cursor: pointer;
    font-size: 1.05rem;
  }
  .acts input {
    width: 1.15rem;
    height: 1.15rem;
    accent-color: var(--teal);
  }

  .overview {
    list-style: none;
    margin: 0.75rem 0 0;
    padding: 0;
  }
  .overview li {
    display: grid;
    grid-template-columns: 3.2rem 12rem 1fr;
    gap: 0 0.75rem;
    align-items: baseline;
    padding: 0.55rem 0.4rem;
    border-top: 1px solid var(--line);
    font-size: 0.9375rem;
  }
  .overview li.hot {
    background: color-mix(in srgb, var(--teal) 10%, transparent);
  }
  .bar {
    align-self: center;
    height: 6px;
    border-radius: 3px;
    background: var(--line);
    overflow: hidden;
  }
  .bar i {
    display: block;
    height: 100%;
    background: var(--teal);
  }
  .link {
    all: unset;
    cursor: pointer;
    font-weight: 600;
    text-decoration: underline;
    text-decoration-color: var(--line-strong);
    text-underline-offset: 3px;
  }
  .link:hover {
    text-decoration-color: var(--ink);
  }
  .link:focus-visible {
    outline: 2px solid var(--ink);
    outline-offset: 2px;
  }
  .hint {
    color: var(--muted);
  }

  button:not(.link) {
    font: 600 0.875rem var(--body);
    color: var(--ink);
    background: transparent;
    border: 1px solid var(--line-strong);
    border-radius: 6px;
    padding: 0.4rem 0.8rem;
    cursor: pointer;
  }
  button:not(.link):hover {
    background: var(--bg);
  }
  button:not(.link):focus-visible {
    outline: 2px solid var(--ink);
    outline-offset: 2px;
  }

  @media (max-width: 52rem) {
    .layout {
      grid-template-columns: 1fr;
    }
    .picker {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(14rem, 1fr));
    }
  }
  @media (max-width: 40rem) {
    .overview li {
      grid-template-columns: 3.2rem 1fr;
    }
    .hint {
      grid-column: 2;
    }
  }
</style>
