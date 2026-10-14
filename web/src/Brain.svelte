<script>
  import { REGIONS, BRAIN_PATH, SULCI } from './lib/regions.js';
  import { ACTIVITIES, ALL_COLOR } from './lib/activities.js';

  let { engine, selected, hovered = null, onhover = () => {} } = $props();

  const isAll = $derived(selected === engine.ALL);
  const color = $derived(isAll ? ALL_COLOR : ACTIVITIES[selected].color);

  // 0..1 shading strength for a region, computed from the Zig engine's data.
  function level(i) {
    if (isAll) return (engine.overlap(i) / engine.activityCount) * 0.8;
    const w = engine.weight(selected, i);
    return w === 2 ? 0.62 : w === 1 ? 0.3 : 0;
  }
</script>

{#snippet region(r, i)}
  {@const lv = level(i)}
  <ellipse
    class="reg"
    class:hot={hovered === i}
    cx={r.cx}
    cy={r.cy}
    rx={r.rx}
    ry={r.ry}
    transform={r.rotate ? `rotate(${r.rotate} ${r.cx} ${r.cy})` : undefined}
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

<svg viewBox="0 0 680 400" role="img" aria-labelledby="brain-title brain-desc">
  <title id="brain-title">Left side of the human brain</title>
  <desc id="brain-desc">
    The front of the brain is on the left. Regions used by the selected activity are shaded.
  </desc>

  <defs>
    <clipPath id="brain-clip"><path d={BRAIN_PATH} /></clipPath>
  </defs>

  <path class="stem" d="M392 296 L432 296 L424 372 L402 372 Z" />

  {#each REGIONS as r, i}
    {#if r.outside}{@render region(r, i)}{/if}
  {/each}

  <path class="cortex" d={BRAIN_PATH} />
  {#each SULCI as d}
    <path class="sulcus" {d} />
  {/each}

  <g clip-path="url(#brain-clip)">
    {#each REGIONS as r, i}
      {#if !r.outside}{@render region(r, i)}{/if}
    {/each}
  </g>

  {#each REGIONS as r, i}
    <text
      class="lab"
      class:on={level(i) > 0}
      x={r.label[0]}
      y={r.label[1]}
      text-anchor="middle"
      dominant-baseline="central"
    >
      {r.short}
    </text>
  {/each}

  <text class="side" x="64" y="190" text-anchor="middle">Front</text>
  <text class="side" x="636" y="190" text-anchor="middle">Back</text>
</svg>

<style>
  svg {
    display: block;
    width: 100%;
    height: auto;
  }
  .cortex {
    fill: var(--tissue);
    stroke: var(--line-strong);
    stroke-width: 1.2;
  }
  .stem {
    fill: var(--tissue);
    stroke: var(--line-strong);
    stroke-width: 0.8;
  }
  .sulcus {
    fill: none;
    stroke: var(--line-strong);
    stroke-width: 0.8;
    opacity: 0.55;
  }
  .reg {
    transition:
      fill-opacity 0.3s ease,
      stroke 0.3s ease;
  }
  .reg.hot {
    stroke: var(--ink);
    stroke-width: 2;
    stroke-dasharray: 0;
  }
  .lab {
    font: 400 12px var(--body);
    fill: var(--muted);
    pointer-events: none;
    transition: fill 0.3s ease;
  }
  .lab.on {
    fill: var(--ink);
    font-weight: 600;
  }
  .side {
    font: 400 12px var(--body);
    fill: var(--muted);
  }
  @media (prefers-reduced-motion: reduce) {
    .reg,
    .lab {
      transition: none;
    }
  }
</style>
