<script>
  import { format } from 'timeago.js';

  import Protoboard from '../../../components/protoboard.js';
  import TextAreaAtom from '../../atoms/TextArea.svelte';

  export let scope;
  export let updateResults;
  export let models;

  let state = 'ready';

  const payload = {
    scope: scope,
    model: 'text-embedding-ada-002',
    distance: 0.8,
    query: '',
    limit: 3
  };

  const sendForm = async (query) => {
    state = 'loading';

    if (query !== undefined) payload.query = query;

    updateResults({ state: 'loading', results: [], query: payload.query });

    const results = await Protoboard.post('/glimpses/search', payload);

    if (results['success']) {
      updateResults({ state: 'ready', results: results, query: payload.query });
    } else {
      updateResults({ state: 'error', results: [], query: payload.query });
    }

    state = 'ready';
  };

  const submitForm = () => {
    sendForm(undefined);
  };
</script>

<form on:submit|preventDefault={submitForm}>
  <div class="mb-3">
    <select bind:value={payload.model} class="form-select" aria-label="models">
      {#each models as model}
        <option value={model.id}>{model.id} | {format(model.created_at)}</option>
      {/each}
    </select>
  </div>

  <div class="row">
    <div class="col">
      <div class="input-group">
        <div class="input-group-text">Limit</div>
        <input bind:value={payload.limit} type="text" class="form-control" />
      </div>
    </div>
    <div class="col">
      <div class="input-group">
        <div class="input-group-text">Distance</div>
        <input bind:value={payload.distance} type="text" class="form-control" />
      </div>
    </div>
  </div>

  <button type="submit" hidden />
</form>

<TextAreaAtom
  label="Enter a thought to explore glimpses..."
  placeholder="put a thought here"
  disabled={state !== 'ready'}
  handler={sendForm}
/>

<style>
  form {
    margin-bottom: 1em;
  }
</style>
