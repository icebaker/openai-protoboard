<script>
  import { onMount } from 'svelte';

  import Protoboard from '../../../components/protoboard.js';

  import StateAtom from '../../atoms/State.svelte';
  import TimeAtom from '../../atoms/Time.svelte';

  export let at;
  export let session;
  export let callback = undefined;
  let state = 'waiting';

  const prepare = () => {
    state = 'waiting';
  };

  const callDelete = async () => {
    state = 'loading';

    const result = await Protoboard.delete(`/sessions/${session.id}`);

    state = result['success'] ? 'success' : 'error';

    if (callback) callback();
  };

  let isMounted = false;

  onMount(() => {
    isMounted = true;
  });

  $: {
    if (isMounted && at) prepare();
  }
</script>

{#if state !== 'waiting'}
  <StateAtom {state} />
{:else}
  <div class="details">
    <p>The following session will be deleted:</p>

    <div class="item">
      {#if session.name}
        <div class="name">{session.name}</div>
      {/if}

      <div class="id">
        <code>{session.id}</code>
      </div>

      <div class="created">
        created <TimeAtom at={session.created_at} />
      </div>
    </div>

    Are you sure?

    <div class="actions text-center border-top">
      <button on:click={callDelete} type="submit" class="btn btn-danger">Delete</button>
      <button type="submit" class="btn btn-secondary" data-bs-dismiss="modal" aria-label="Cancel">
        Cancel
      </button>
    </div>
  </div>
{/if}

<style>
  .details {
    text-align: center;
    margin: 1em 0 0 0;
  }

  .item {
    font-size: 1.4em;
    margin-bottom: 1em;
  }

  .item div {
    padding: 0.2em 0;
  }

  .actions {
    margin-top: 1em;
    padding-top: 1em;
  }
  .actions button {
    margin: 0 0.2em;
  }
</style>
