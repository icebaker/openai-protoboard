<script>
  import { onMount } from 'svelte';

  import Presenter from '../../../helpers/presenter.js';

  import Protoboard from '../../../components/protoboard.js';
  import TimeAtom from '../../atoms/Time.svelte';
  import EmptyAtom from '../../atoms/Empty.svelte';
  import StateAtom from '../../atoms/State.svelte';

  export let at;
  export let scope;

  let state = 'loading';
  let knowledges = undefined;

  const load = async () => {
    knowledges = (await Protoboard.get('/knowledges', { scope: scope }))['success'];

    state = 'success';
  };

  let isMounted = false;

  onMount(async () => {
    isMounted = true;
    await load();
  });

  $: {
    if (isMounted && at) load();
  }
</script>

<div>
  {#if state === 'loading'}
    <StateAtom {state} />
  {:else if knowledges.length === 0}
    <EmptyAtom />
  {:else}
    <table class="table">
      <thead>
        <tr>
          <th scope="col">Knowledge</th>
          <th scope="col" width="1" class="text-center">Glimpses</th>
          <th scope="col" width="1" class="text-center">Tokens</th>
        </tr>
      </thead>
      <tbody>
        {#each knowledges as knowledge}
          <tr>
            <td>
              <a
                href={Protoboard.download_link(knowledge)}
                class="font-monospace d-inline-block text-truncate"
                style="max-width: 30em;"
              >
                {knowledge.source}
              </a>
            </td>
            <td class="text-center">
              {Presenter.number(knowledge.glimpses.length)}
            </td>
            <td class="text-center">
              {Presenter.number(knowledge.tokens)}
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  {/if}
</div>
