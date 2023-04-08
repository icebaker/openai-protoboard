<script>
  import { onMount, onDestroy } from 'svelte';

  import { format } from 'timeago.js';

  import Presenter from '../../helpers/presenter.js';

  export let at;

  let timeout = undefined;
  let spanElement = undefined;
  let formatted = format(at);

  export let expirable = false;
  export let expired = false;
  export let seconds = 60;

  const updateFormat = () => {
    expired = false;
    formatted = format(at);
    if (formatted.includes('ago')) {
      if (expirable) expired = true;
    }
    timeout = setTimeout(updateFormat, seconds * 1000);
  };

  let isMounted = false;

  onMount(() => {
    isMounted = true;

    if (spanElement) new bootstrap.Tooltip(spanElement);
    timeout = setTimeout(updateFormat, seconds * 1000);
  });

  $: {
    if (isMounted && at) updateFormat();
  }

  onDestroy(() => clearTimeout(timeout));
</script>

{#if at === null || at === undefined}
  -
{:else}
  <span
    class={expired ? 'text-danger-emphasis text-decoration-line-through' : ''}
    bind:this={spanElement}
    data-bs-toggle="tooltip"
    data-bs-title={Presenter.dateTime(at)}
  >
    {formatted}
  </span>
{/if}
