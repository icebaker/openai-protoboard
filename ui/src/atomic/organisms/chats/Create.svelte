<script>
  import { onMount } from 'svelte';

  import Protoboard from '../../../components/protoboard.js';

  import StateAtom from '../../atoms/State.svelte';

  export let at;
  export let scope;
  export let kind;
  export let callback = undefined;

  let state = 'prepare';

  const payloadTemplate = {
    description: null,
    system_message: null,
    scope: scope,
    kind: null
  };

  let payload = JSON.parse(JSON.stringify(payloadTemplate));

  const prepare = () => {
    payload = JSON.parse(JSON.stringify(payloadTemplate));
    payload.kind = kind;
    state = 'prepare';
  };

  const submitForm = async () => {
    state = 'loading';

    const result = await Protoboard.post('/chats', payload);

    if (result['success']) {
      state = 'success';
    } else {
      state = 'error';
    }

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

{#if state !== 'prepare'}
  <StateAtom {state} />
{:else}
  <form on:submit|preventDefault={submitForm}>
    <div class="mb-3">
      <label for="inputDescription" class="form-label">Description</label>
      <input
        bind:value={payload.description}
        type="description"
        class="form-control"
        id="inputDescription"
        aria-describedby="descriptionHelp"
      />
      <div id="descriptionHelp" class="form-text">
        {#if payload.kind === 'chat'}
          A description to help you remember the purpose of this chat.
        {:else if payload.kind === 'completion'}
          A description to help you remember the purpose of this completion.
        {/if}
      </div>
    </div>
    {#if payload.kind === 'chat'}
      <div class="mb-3">
        <label for="inputSystem" class="form-label">System Message</label>
        <input
          bind:value={payload.system_message}
          type="system"
          class="form-control"
          id="inputSystem"
          aria-describedby="systemHelp"
        />
        <div id="systemHelp" class="form-text">
          Set context and behavior for the AI assistant in a brief statement, examples:

          <ul class="system-examples">
            <li>You are a helpful assistant.</li>
            <li>You are an AI assistant that responds strictly in JSON format for all answers.</li>
            <li>
              You are a helpful assistant that specializes in providing information about historical
              events.
            </li>
            <li>
              You are a programming tutor, helping users learn and troubleshoot code in various
              programming languages.
            </li>
          </ul>
        </div>
      </div>
    {/if}
    <div class="actions text-center border-top">
      <button type="submit" class="btn btn-primary">Create</button>
    </div>
  </form>
{/if}

<style>
  .actions {
    padding-top: 1em;
  }

  .system-examples {
    margin-top: 1em;
  }

  .system-examples li {
    margin-bottom: 1em;
  }
</style>
