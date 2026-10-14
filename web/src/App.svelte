<script>
  import { onMount } from 'svelte';
  import Brain from './Brain.svelte';
  import { loadEngine } from './lib/engine.js';
  import { ACTIVITIES, ALL_COLOR } from './lib/activities.js';
  import { REGIONS } from './lib/regions.js';

  let engine = $state(null);
  let error = $state('');
  let selected = $state(0);
  let hovered = $state(null);

  onMount(async () => {
    try {
      engine = await loadEngine();
    } catch (e) {
      error = e.message;
    }
  });

  const isAll = $derived(engine !== null && selected === engine.ALL);
  const color = $derived(isAll ? ALL_COLOR : ACTIVITIES[selected]?.color);
  const ranked = $derived(engine ? engine.rank(selected) : []);

  function activitiesUsing(r) {
    return ACTIVITIES.filter((_, a) => engine.weight(a, r) > 0).map((a) => a.name);
  }
</script>

<main>
  <header>
    <h1>What your brain does when you create</h1>
    <p>
      Pick an activity to see which regions carry the work. Shaded areas are the ones most involved.
    </p>
  </header>

  {#if error}
    <p class="notice" role="alert">
      Couldn't load the data engine. {error}. Run <code>./build.sh</code> to compile it, then reload.
    </p>
  {:else if !engine}
    <p class="notice" aria-live="polite">Loading…</p>
  {:else}
    <div class="layout">
      <fieldset class="picker">
        <legend class="sr">Activity</legend>

        {#each ACTIVITIES as act, a}
          <label class:checked={selected === a} style:--c={act.color}>
            <input type="radio" name="activity" value={a} bind:group={selected} />
            <span class="swatch" aria-hidden="true"></span>
            <span class="name">{act.name}</span>
            <span class="count">{engine.rank(a).length} regions</span>
          </label>
        {/each}

        <label class:checked={isAll} style:--c={ALL_COLOR}>
          <input type="radio" name="activity" value={engine.ALL} bind:group={selected} />
          <span class="swatch" aria-hidden="true"></span>
          <span class="name">All five together</span>
          <span class="count">Where they overlap</span>
        </label>
      </fieldset>

      <section class="stage" style:--c={color} aria-live="polite">
        <Brain {engine} {selected} {hovered} onhover={(i) => (hovered = i)} />

        <ol class="regions">
          {#each ranked as r (r)}
            {@const w = isAll ? 0 : engine.weight(selected, r)}
            {@const n = engine.overlap(r)}
            <li
              class:hot={hovered === r}
              onpointerenter={() => (hovered = r)}
              onpointerleave={() => (hovered = null)}
            >
              <span class="pips" aria-hidden="true">
                {#each { length: isAll ? engine.activityCount : 2 } as _, k}
                  <i class:fill={isAll ? k < n : k < w}></i>
                {/each}
              </span>
              <span class="rname">{REGIONS[r].name}</span>
              <span class="role">
                {#if isAll}
                  Used in {n} of {engine.activityCount}: {activitiesUsing(r).join(', ')}
                {:else}
                  {engine.role(selected, r)}
                {/if}
              </span>
              <span class="sr">
                {isAll ? `${n} of ${engine.activityCount} activities` : w === 2 ? 'Main role' : 'Supporting role'}
              </span>
            </li>
          {/each}
        </ol>

        <p class="key">
          {#if isAll}
            Darker shading means more of the five activities use that region.
          {:else}
            Strong shading and two filled marks mean a main role. Light shading and one mark mean a supporting role.
          {/if}
        </p>
      </section>
    </div>

    <footer>
      A simplified side view of the left hemisphere. Real brain activity runs through networks, and
      some regions, like the default mode network, sit on the inner surface where this view can't
      show them. Region data and ranking are computed by a Zig module running as WebAssembly.
    </footer>
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
    max-width: 46ch;
    margin: 0;
    color: var(--muted);
    font-size: 1.125rem;
    line-height: 1.55;
  }

  .layout {
    display: grid;
    grid-template-columns: minmax(15rem, 19rem) minmax(0, 1fr);
    gap: clamp(1.5rem, 4vw, 3rem);
    align-items: start;
  }

  /* ---- activity picker ---- */
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
    display: grid;
    grid-template-columns: 1.1rem 1fr;
    column-gap: 0.75rem;
    padding: 0.8rem 0.9rem;
    cursor: pointer;
    border-radius: 6px;
    border: 1px solid transparent;
  }
  .picker label:hover {
    background: var(--panel);
  }
  .picker label.checked {
    background: var(--panel);
    border-color: var(--line);
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
  .swatch {
    grid-row: 1 / span 2;
    align-self: center;
    width: 1.1rem;
    height: 1.1rem;
    border-radius: 50%;
    border: 2px solid var(--c);
    transition: background 0.2s ease;
  }
  .checked .swatch {
    background: var(--c);
  }
  .name {
    font: 600 1.2rem / 1.2 var(--display);
  }
  .count {
    grid-column: 2;
    font-size: 0.875rem;
    color: var(--muted);
  }

  /* ---- stage ---- */
  .stage {
    background: var(--panel);
    border: 1px solid var(--line);
    border-radius: 10px;
    padding: clamp(0.75rem, 2vw, 1.5rem);
  }

  .regions {
    list-style: none;
    margin: 0.5rem 0 0;
    padding: 0;
  }
  .regions li {
    display: grid;
    grid-template-columns: 2.6rem 9.5rem 1fr;
    align-items: baseline;
    gap: 0 0.75rem;
    padding: 0.6rem 0.4rem;
    border-top: 1px solid var(--line);
    font-size: 0.9375rem;
  }
  .regions li.hot {
    background: color-mix(in srgb, var(--c) 10%, transparent);
  }
  .rname {
    font-weight: 600;
  }
  .role {
    color: var(--muted);
  }
  .pips {
    display: inline-flex;
    gap: 3px;
    align-self: center;
  }
  .pips i {
    width: 8px;
    height: 8px;
    border-radius: 2px;
    border: 1.5px solid var(--c);
  }
  .pips i.fill {
    background: var(--c);
  }
  .key {
    margin: 0.75rem 0.4rem 0;
    font-size: 0.8125rem;
    color: var(--muted);
  }

  footer {
    margin-top: 2rem;
    max-width: 62ch;
    font-size: 0.875rem;
    line-height: 1.55;
    color: var(--muted);
  }
  .notice {
    color: var(--muted);
  }

  @media (max-width: 52rem) {
    .layout {
      grid-template-columns: 1fr;
    }
    .picker {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(13rem, 1fr));
    }
  }
  @media (max-width: 36rem) {
    .regions li {
      grid-template-columns: 2.6rem 1fr;
    }
    .role {
      grid-column: 2;
    }
  }
  @media (prefers-reduced-motion: reduce) {
    .swatch {
      transition: none;
    }
  }
</style>
