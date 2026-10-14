<script>
  let { page } = $props();
</script>

<nav aria-label="Pages">
  <span class="brand">Brain map</span>
  <a href="#/" aria-current={page === 'activities' ? 'page' : undefined}>Creative activities</a>
  <a href="#/gaps" aria-current={page === 'gaps' ? 'page' : undefined}>Missing areas</a>
</nav>

<style>
  nav {
    max-width: 68rem;
    margin: 0 auto;
    padding: 1.25rem clamp(1rem, 4vw, 2.5rem) 0;
    display: flex;
    align-items: baseline;
    gap: 1.75rem;
    flex-wrap: wrap;
  }
  .brand {
    font: 800 1.125rem var(--display);
    letter-spacing: -0.01em;
    margin-right: auto;
  }
  a {
    color: var(--muted);
    text-decoration: none;
    font-weight: 600;
    padding: 0.35rem 0;
    border-bottom: 2px solid transparent;
  }
  a:hover {
    color: var(--ink);
  }
  a[aria-current='page'] {
    color: var(--ink);
    border-bottom-color: var(--ink);
  }
  a:focus-visible {
    outline: 2px solid var(--ink);
    outline-offset: 3px;
  }
</style>
