<script>
  import { onMount } from 'svelte';

  import Content from './Content.svelte';
  import Protoboard from '../../components/protoboard.js';

  export let glimpse;

  let state = 'closed';

  const toggle = () => {
    if (state === 'closed') {
      state = 'open';
    } else {
      state = 'closed';
    }
  };

  let protoboardAPI = undefined;

  let ready = false;
  onMount(async () => {
    protoboardAPI = await Protoboard.api();
    ready = true;
  });

  const downloadLink = (glimpse) => {
    return Protoboard.download_link_from_glimpse(protoboardAPI, glimpse);
  };
</script>

{#if ready}
  <div class="glimpse">
    <div class="row">
      {#if $$slots.default}
        <div class="col-5">
          <slot />
        </div>
      {/if}
      <div class="col text-end">
        <span class="text-warning-emphasis download">
          <i class="bi bi-file-binary" />
          <a
            href={downloadLink(glimpse)}
            class="font-monospace d-inline-block text-truncate"
            style="max-width: 14em;"
          >
            {glimpse.source}
          </a>
        </span>
        <button on:click={toggle} type="button" class="toggler btn btn-sm btn-outline-secondary">
          {#if state === 'closed'}
            <i class="bi bi-chevron-bar-down" />
          {:else}
            <i class="bi bi-chevron-bar-up" />
          {/if}
        </button>
      </div>
    </div>
    {#if state === 'open'}
      <div class="content border-end text-start">
        <Content content={glimpse.content} />
      </div>
    {/if}
  </div>
{/if}

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

  .download a {
    vertical-align: middle;
  }
</style>
