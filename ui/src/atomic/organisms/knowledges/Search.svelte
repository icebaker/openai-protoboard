<script>
  import { onMount } from 'svelte';

  import Presenter from '../../../helpers/presenter.js';

  import Protoboard from '../../../components/protoboard.js';
  import TimeAtom from '../../atoms/Time.svelte';
  import EmptyAtom from '../../atoms/Empty.svelte';
  import StateAtom from '../../atoms/State.svelte';
  import Glimpse from '../../molecules/Glimpse.svelte';

  import Prompt from './Prompt.svelte';

  export let scope;

  let query = undefined;

  let state = 'prepare';
  let glimpses = [];

  const updateResults = (params) => {
    glimpses = params.results.success;

    query = params.query;

    state = params.state;
  };

  let formState = 'loading';
  let models = undefined;

  const prepareForm = async () => {
    models = (await Protoboard.get('/models', { purpose: 'embedding' }))['success'];

    formState = 'ready';
  };

  onMount(() => {
    prepareForm();
  });
</script>

<div>
  {#if formState == 'ready'}
    <Prompt {scope} {updateResults} {models} />
  {/if}

  {#if query !== undefined}
    <div class="query">
      <blockquote class="blockquote">
        <p class="text-center text-info-emphasis">
          "{query}"
        </p>
      </blockquote>
    </div>
  {/if}

  {#if state === 'loading' || state === 'error'}
    <StateAtom {state} />
  {:else if !Array.isArray(glimpses) || glimpses.length === 0}
    {#if query !== undefined}
      <EmptyAtom message="No glimpses found." />
    {:else}
      <EmptyAtom message="Here you can explore glimpses." />
    {/if}
  {:else}
    {#each glimpses as glimpse}
      <div class="glimpse border-top">
        <Glimpse {glimpse}>
          Centainty: <span class="text-danger-emphasis"
            >{Presenter.number(glimpse._additional.certainty, 0, 10)}</span
          >
        </Glimpse>
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
    padding-top: 1em;
    margin: 0;
    margin-bottom: -0.2em;
  }
</style>
