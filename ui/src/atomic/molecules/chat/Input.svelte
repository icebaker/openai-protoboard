<script>
  import { format } from 'timeago.js';

  import { onMount } from 'svelte';

  import Protoboard from '../../../components/protoboard.js';
  import TextAreaAtom from '../../atoms/TextArea.svelte';

  export let chat;
  export let updateHistory;
  export let action;

  let state = 'ready';

  let errorMessage = undefined;

  const payload = {
    verbose: true,
    id: chat.id,
    content: '',
    suffix: '',
    message: '',
    // model: chat.kind === 'completion' ? 'text-davinci-003' : 'gpt-3.5-turbo',
    // model: chat.kind === 'completion' ? 'text-davinci-edit-001' : 'gpt-3.5-turbo',
    temperature: 0.7,
    max_tokens: 1024,
    user: chat.id,
    glimpses: 1,
    distance: 0.8
  };

  const sendMessage = async (message) => {
    errorMessage = undefined;

    if (message !== undefined) {
      payload.message = message;
    }

    state = 'loading';

    if (action !== 'edit') {
      payload.content = '';
    }

    if (action !== 'complete') {
      payload.suffix = '';
    }

    if (chat.kind !== 'chat' && action !== 'edit') {
      payload.glimpses = 0;
    }

    payload.temperature = parseFloat(payload.temperature);
    payload.max_tokens = parseInt(payload.max_tokens, 10);
    payload.glimpses = parseInt(payload.glimpses, 10);
    payload.distance = parseFloat(payload.distance);

    const response = await Protoboard.post(`/chats/${chat.id}`, payload);

    if (response['error']) {
      state = 'error';
      errorMessage = response['error']['message'];
    } else if (!response['success']) {
      state = 'error';
    } else {
      state = 'ready';
      updateHistory(response['success'].chat.history);
    }
  };

  let formState = 'loading';
  let models = undefined;
  let selectedModels = [];

  let previousAction = undefined;

  const filterModels = () => {
    if (previousAction === action || !models) {
      return selectedModels;
    }

    previousAction = action;

    if (chat.kind === 'completion' && action === 'complete') {
      selectedModels = models.filter((model) => {
        return model.purpose === 'completion';
      });
      payload.model = 'text-davinci-003';
    } else if (chat.kind === 'completion' && action === 'edit') {
      selectedModels = models.filter((model) => {
        return model.purpose === 'edit';
      });
      payload.model = 'text-davinci-edit-001';
    } else {
      selectedModels = models.filter((model) => {
        return model.purpose === 'chat';
      });
      payload.model = 'gpt-3.5-turbo';
    }

    return selectedModels;
  };

  const prepareForm = async () => {
    // if (chat.kind === 'completion') {
    //   models = (await Protoboard.get('/models', { purpose: 'completion' }))['success'];
    // } else {
    //   models = (await Protoboard.get('/models', { purpose: 'chat' }))['success'];
    // }

    models = (await Protoboard.get('/models'))['success'];
    selectedModels = filterModels();

    formState = 'ready';
  };

  const submitForm = () => {
    sendMessage(undefined);
  };

  let mounted = false;
  onMount(() => {
    prepareForm();
    mounted = true;
  });

  let formLabels = {};

  const buildFormLabels = () => {
    if (chat.kind === 'completion' && action == 'complete') {
      formLabels = {
        label: 'Send an instruction or a beginning to be completed...',
        placeholder: 'put a instruction or beginning here'
      };
    } else if (chat.kind === 'completion' && action == 'edit') {
      formLabels = {
        label: 'Send an instruction...',
        placeholder: 'put a instruction here'
      };
    } else {
      formLabels = {
        label: 'Send a message...',
        placeholder: 'put a message here'
      };
    }
  };

  $: {
    if (mounted && action && models) {
      buildFormLabels();
      selectedModels = filterModels();
    }
  }
</script>

{#if formState === 'ready'}
  <form on:submit|preventDefault={submitForm}>
    <div class="mb-3">
      <select bind:value={payload.model} class="form-select" aria-label="models">
        {#each selectedModels as model}
          <option value={model.id}>{model.title} | {format(model.created_at)}</option>
        {/each}
      </select>
    </div>

    <div class="row">
      <div class="col">
        <div class="input-group">
          <div class="input-group-text">Temperature</div>
          <input bind:value={payload.temperature} type="text" class="form-control" />
        </div>
      </div>
      <div class="col">
        <div class="input-group">
          <div class="input-group-text">Response Maximum Tokens</div>
          <input bind:value={payload.max_tokens} type="text" class="form-control" />
        </div>
      </div>
    </div>

    {#if chat.kind === 'chat' || action === 'edit'}
      <div class="row form-line">
        <div class="col">
          <div class="input-group">
            <div class="input-group-text">Glimpses</div>
            <input bind:value={payload.glimpses} type="text" class="form-control" />
          </div>
        </div>
        <div class="col">
          <div class="input-group">
            <div class="input-group-text">Distance</div>
            <input bind:value={payload.distance} type="text" class="form-control" />
          </div>
        </div>
      </div>
    {/if}

    <button type="submit" hidden />
  </form>
{/if}

{#if action === 'edit'}
  <div class="text-areas">
    <TextAreaAtom
      label="Content"
      placeholder="put a content here"
      disabled={state === 'loading'}
      bind:value={payload.content}
    />
  </div>
{/if}

{#if action === 'complete' && chat.kind === 'completion'}
  <div class="text-areas">
    <TextAreaAtom
      label="Suffix"
      placeholder="put a suffix here"
      disabled={state === 'loading'}
      bind:value={payload.suffix}
    />
  </div>
{/if}

<div class="text-areas">
  <TextAreaAtom
    label={formLabels.label}
    placeholder={formLabels.placeholder}
    disabled={state === 'loading'}
    handler={sendMessage}
    recorder={true}
  />
</div>

{#if state === 'error'}
  <div class="state text-danger-emphasis">
    <i class="bi bi-exclamation-triangle" />
    <p>
      {#if errorMessage}
        {errorMessage}
      {:else}
        Something went wrong.
      {/if}
    </p>
  </div>
{:else if state === 'loading'}
  <div class="state">
    <div class="spinner-grow spinner-grow-sm text-warning-emphasis" role="status">
      <span class="visually-hidden">Loading...</span>
    </div>
    <br />
    <p>Loading, please wait...</p>
  </div>
{/if}

<style>
  .state i {
    display: inline-block;
    font-size: 1.6em;
  }

  .state p {
    margin-top: 0.7em;
  }

  .state {
    padding-top: 2em;
    text-align: center;
  }

  .input-area {
    overflow-y: hidden;
  }

  .form-line {
    margin-top: 1em;
  }

  form {
    margin-bottom: 1em;
  }

  .text-areas {
    margin-bottom: 1em;
  }
</style>
