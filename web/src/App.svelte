<script>
  import Nav from './Nav.svelte';
  import Activities from './Activities.svelte';
  import Gaps from './Gaps.svelte';

  const parse = () => (location.hash.startsWith('#/gaps') ? 'gaps' : 'activities');
  let page = $state(parse());

  $effect(() => {
    const onChange = () => {
      page = parse();
      window.scrollTo(0, 0);
    };
    window.addEventListener('hashchange', onChange);
    return () => window.removeEventListener('hashchange', onChange);
  });

  $effect(() => {
    document.title =
      page === 'gaps'
        ? 'Which brain areas are your activities missing?'
        : 'Which parts of the brain do creative tasks use?';
  });
</script>

<Nav {page} />

{#if page === 'gaps'}
  <Gaps />
{:else}
  <Activities />
{/if}
