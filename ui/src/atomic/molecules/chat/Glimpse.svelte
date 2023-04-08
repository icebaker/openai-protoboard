<script>
  import Message from './Message.svelte';
  import Protoboard from '../../../components/protoboard.js';

  export let event;

  let state = 'closed';

  const toggle = () => {
    if (state === 'closed') {
      state = 'open';
    } else {
      state = 'closed';
    }
  };
</script>

<div class="glimpse text-end">
  <span class="text-warning-emphasis">
    <i class="bi bi-file-binary" />
    <a href={Protoboard.download_link_from_glimpse(event.glimpse)}>
      {event.glimpse.source}
    </a>
  </span>
  <button on:click={toggle} type="button" class="toggler btn btn-sm btn-outline-secondary">
    {#if state === 'closed'}
      <i class="bi bi-chevron-bar-down" />
    {:else}
      <i class="bi bi-chevron-bar-up" />
    {/if}
  </button>
  {#if state === 'open'}
    <div class="content border-end text-start">
      <Message message={event.input.message.content} />
    </div>
  {/if}
</div>

<style>
  .glimpse {
    margin-bottom: 1em;
  }

  .toggler {
    margin-left: 0.6em;
  }

  .content {
    margin: 1em 1em 0 1em;
    padding-right: 1em;
  }
</style>
