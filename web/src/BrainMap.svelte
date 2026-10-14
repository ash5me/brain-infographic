<script>
  import { AREAS, CALLOSUM_PATH } from './lib/areas.js';
  import { BRAIN_PATH, SULCI } from './lib/regions.js';

  // view:    'lateral' (outer surface) or 'medial' (inner surface)
  // levels:  shading strength 0..1 for each area, same order as AREAS
  // labelled: indices of areas whose labels are shown
  let { view, levels, labelled = [], hovered = null, onhover = () => {} } = $props();

  const clipId = $derived(`clip-${view}`);
  const color = 'var(--teal)';
</script>

{#snippet shape(s, i)}
  {@const lv = levels[i]}
  <ellipse
    class="reg"
    class:deep={s.deep}
    class:hot={hovered === i}
    cx={s.cx}
    cy={s.cy}
    rx={s.rx}
    ry={s.ry}
    transform={s.rotate ? `rotate(${s.rotate} ${s.cx} ${s.cy})` : undefined}
    fill={lv > 0 ? color : 'none'}
    fill-opacity={lv}
    stroke={lv > 0 ? color : 'var(--line-strong)'}
    stroke-dasharray={lv > 0 ? '0' : '3 3'}
    stroke-width={lv > 0 ? 1 : 0.6}
    role="presentation"
    onpointerenter={() => onhover(i)}
    onpointerleave={() => onhover(null)}
  />
{/snippet}

<svg viewBox="95 40 515 360" role="img" aria-label={view === 'lateral' ? 'Outer surface of the brain' : 'Inner surface of the brain'}>
  <defs>
    <clipPath id={clipId}><path d={BRAIN_PATH} /></clipPath>
  </defs>

  <path class="stem" d="M392 296 L432 296 L424 372 L402 372 Z" />

  {#each AREAS as a, i}
    {#each a[view]?.shapes ?? [] as s}
      {#if s.outside}{@render shape(s, i)}{/if}
    {/each}
  {/each}

  <path class="cortex" d={BRAIN_PATH} />

  {#if view === 'lateral'}
    {#each SULCI as d}<path class="fold" {d} />{/each}
  {:else}
    <ellipse class="thalamus" cx="372" cy="192" rx="34" ry="22" />
    <path class="callosum" d={CALLOSUM_PATH} />
  {/if}

  <g clip-path={`url(#${clipId})`}>
    {#each AREAS as a, i}
      {#each a[view]?.shapes ?? [] as s}
        {#if !s.outside}{@render shape(s, i)}{/if}
      {/each}
    {/each}
  </g>

  {#each labelled as i}
    {#each AREAS[i][view]?.labels ?? [] as l}
      <text class="lab" x={l.x} y={l.y} text-anchor="middle" dominant-baseline="central">{l.text}</text>
    {/each}
  {/each}

</svg>

<style>
  svg {
    display: block;
    width: 100%;
    height: auto;
  }
  .cortex,
  .stem {
    fill: var(--tissue);
    stroke: var(--line-strong);
    stroke-width: 1.2;
  }
  .fold {
    fill: none;
    stroke: var(--line-strong);
    stroke-width: 0.8;
    opacity: 0.55;
  }
  .callosum {
    fill: none;
    stroke: var(--line-strong);
    stroke-width: 7;
    stroke-linecap: round;
    opacity: 0.45;
  }
  .thalamus {
    fill: var(--line);
    opacity: 0.6;
  }
  .reg {
    transition:
      fill-opacity 0.3s ease,
      stroke 0.3s ease;
  }
  .reg.deep {
    stroke-dasharray: 2 3;
  }
  .reg.hot {
    stroke: var(--ink);
    stroke-width: 2;
  }
  .lab {
    font: 600 12px var(--body);
    fill: var(--ink);
    paint-order: stroke;
    stroke: var(--tissue);
    stroke-width: 4px;
    stroke-linejoin: round;
    pointer-events: none;
  }
  @media (prefers-reduced-motion: reduce) {
    .reg {
      transition: none;
    }
  }
</style>
