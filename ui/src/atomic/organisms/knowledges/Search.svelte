<script>
  import { onMount } from 'svelte';

  import Presenter from '../../../helpers/presenter.js';

  import Protoboard from '../../../components/protoboard.js';
  import TimeAtom from '../../atoms/Time.svelte';
  import EmptyAtom from '../../atoms/Empty.svelte';
  import StateAtom from '../../atoms/State.svelte';

  import Prompt from './Prompt.svelte';

  export let scope;

  let query = undefined;

  let state = 'prepare';
  let glimpses = [];

  const updateResults = (params) => {
    glimpses = params.results;

    query = params.query;

    state = params.state;
  };
</script>

<div>
  <Prompt {scope} {updateResults} />

  {#if query !== undefined}
    <div class="query">
      <blockquote class="blockquote">
        <p class="text-center text-info-emphasis">
          "{query}"
        </p>
      </blockquote>
    </div>
  {/if}

  {#if state === 'loading'}
    <StateAtom {state} />
  {:else if glimpses.length === 0}
    {#if query !== undefined}
      <EmptyAtom message="No glimpses found." />
    {:else}
      <EmptyAtom message="Here you can explore glimpses." />
    {/if}
  {:else}
    {#each glimpses as glimpse}
      <div class="glimpse">
        <div class="row glimpse-header border-bottom">
          <div class="col key-value">
            <strong>Knowledge:</strong>
            <span class="text-danger-emphasis font-monospace">
              <i class="bi bi-file-binary" />
              {glimpse.source}
            </span>
          </div>

          <div class="col key-value">
            <strong>Certainty:</strong>
            <span class="text-warning-emphasis">
              {Presenter.number(glimpse._additional.certainty, undefined, 10)}
            </span>
          </div>
        </div>

        <div class="font-monospace glimpse-content text-wrap text-break">
          {glimpse.content}
        </div>
      </div>
    {/each}
  {/if}
</div>

<style>
  .query {
    padding: 3em 0 0em 0;
    font-style: italic;
  }

  .query p {
    font-size: 1.2em;
  }

  .glimpse {
    margin: 2em 0 4em;
    padding-top: 2em;
  }

  .glimpse-header {
    padding-bottom: 1em;
  }

  .key-value {
    text-align: center;
  }

  .glimpse-content {
    padding: 1em;
  }
</style>
