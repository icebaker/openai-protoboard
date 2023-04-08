<script>
  import { onMount } from 'svelte';

  import Protoboard from '../../../components/protoboard.js';

  import StateAtom from '../../atoms/State.svelte';

  export let at;
  export let callback = undefined;

  let state = 'prepare';

  const payloadTemplate = {
    name: null
  };

  let payload = JSON.parse(JSON.stringify(payloadTemplate));

  const prepare = () => {
    payload = JSON.parse(JSON.stringify(payloadTemplate));
    state = 'prepare';
  };

  const submitForm = async () => {
    state = 'loading';

    const result = await Protoboard.post('/sessions', payload);

    if (result['success']) {
      state = 'success';
    } else {
      state = 'error';
    }

    if (callback) callback();
  };

  let isMounted = false;

  onMount(async () => {
    isMounted = true;
  });

  $: {
    if (isMounted && at) prepare();
  }
</script>

{#if state !== 'prepare'}
  <StateAtom {state} />
{:else}
  <form on:submit|preventDefault={submitForm}>
    <div class="mb-3">
      <label for="inputName" class="form-label">Name</label>
      <input
        bind:value={payload.name}
        type="name"
        class="form-control"
        id="inputName"
        aria-describedby="nameHelp"
      />
      <div id="nameHelp" class="form-text">
        A name to help you remember the purpose of this session.
      </div>
    </div>
    <div class="actions text-center border-top">
      <button type="submit" class="btn btn-primary">Create</button>
    </div>
  </form>
{/if}

<style>
  .actions {
    padding-top: 1em;
  }
</style>
