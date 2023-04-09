<script>
  import { onMount } from 'svelte';
  import { format } from 'timeago.js';

  import { nanoid } from 'nanoid';

  import Presenter from '../../../helpers/presenter.js';
  import Protoboard from '../../../components/protoboard.js';

  export let event = undefined;
  export let at;

  export let scope = undefined;
  export let callback;
  let files = undefined;

  let state = 'waiting';

  let previousAt = null;

  let estimations = {};
  let estimationsOverview = null;

  const payloadTemplate = {
    intersections: true,
    tokens_per_glimpse: 1024,
    model: 'text-embedding-ada-002',
    scope: scope
  };

  let payload = JSON.parse(JSON.stringify(payloadTemplate));

  let models;

  const prepareForm = async () => {
    payload = JSON.parse(JSON.stringify(payloadTemplate));
    state = 'estimating';
    previousAt = at;
    estimations = {};
    estimationsOverview = null;
    if (event.target.files) {
      files = event.target.files;
    } else {
      files = event.dataTransfer.files;
    }
    models = (await Protoboard.get('/models', { purpose: 'embedding' }))['success'];
    await estimateTokens();
  };

  const estimateTokens = async () => {
    const promises = [];

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const promise = Protoboard.estimateTokens(payload.model, file, i);
      promises.push(promise);
    }

    try {
      const result = await Promise.all(promises);

      result.forEach((response) => {
        estimations[response.success.index] = response.success;
      });

      estimationsOverview = (
        await Protoboard.overviewEstimateTokens(result.map((response) => response.success))
      ).success;

      state = 'prepare';
    } catch (error) {
      state = 'error';
      console.error('An error occurred while estimating tokens:', error);
      if (callback) callback();
    }
  };

  const submitForm = async () => {
    state = 'loading';

    const promises = [];

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const promise = Protoboard.uploadKnowledge(payload, file);
      promises.push(promise);
    }

    try {
      await Promise.all(promises);
      state = 'success';
      if (callback) callback();
    } catch (error) {
      state = 'error';
      if (callback) callback();
      console.error('An error occurred while uploading files:', error);
    }
  };

  let isMounted = false;

  onMount(() => {
    isMounted = true;
  });

  $: {
    if (isMounted && at !== previousAt) prepareForm();
  }

  const estimateFor = (index) => {
    return estimations[index];
  };
</script>

{#if state === 'estimating'}
  <div class="loading">
    <div class="spinner-border text-info-emphasis" role="status">
      <span class="visually-hidden">Loading...</span>
    </div>

    <p>
      Estimating the potential cost of indexing those files.
      <br />
      This may take a while. Please be patient.
    </p>
  </div>
{:else if state === 'loading'}
  <div class="loading">
    <div class="spinner-border text-info-emphasis" role="status">
      <span class="visually-hidden">Loading...</span>
    </div>

    <p>
      Uploading and indexing files. This may take a while.
      <br />
      Please be patient.
    </p>
  </div>
{:else if state === 'error'}
  <div class="state">
    <i class="bi bi-check-circle-fill text-danger" />
    <p>
      Oops! There was an issue uploading and indexing your files.
      <br />
      Please give it another try.
    </p>
  </div>
{:else if state === 'success'}
  <div class="state">
    <i class="bi bi-check-circle-fill text-success" />
    <p>
      Files indexed!
      <br />
      They'll now help me better answer your questions.
    </p>
  </div>
{:else if state === 'prepare'}
  <form on:submit|preventDefault={submitForm}>
    <table class="table">
      <thead>
        <tr>
          <th scope="col">File</th>
          <th scope="col" class="text-center">Tokens</th>
          <th scope="col" class="text-center">Cost</th>
        </tr>
      </thead>
      <tbody>
        {#each files as file, i}
          <tr>
            <td>
              <span class="font-monospace d-inline-block text-truncate" style="max-width: 30em;">
                {file.name}
              </span>
            </td>
            <td class="text-center text-warning-emphasis">
              {Presenter.number((payload.intersections ? 2 : 1) * estimateFor(i).tokens)}
            </td>
            <td class="text-center text-danger-emphasis">
              {Presenter.money(
                (payload.intersections ? 2 : 1) * estimateFor(i).dollars,
                undefined,
                10
              )}
            </td>
          </tr>
        {/each}
        <tr>
          <td class="text-end">
            <em> Estimated Total </em>
          </td>
          <td class="text-center text-warning">
            <strong>
              {Presenter.number((payload.intersections ? 2 : 1) * estimationsOverview.tokens)}
            </strong>
          </td>
          <td class="text-center text-danger">
            <strong>
              {Presenter.money(
                (payload.intersections ? 2 : 1) * estimationsOverview.dollars,
                undefined,
                10
              )}
            </strong>
          </td>
        </tr>
      </tbody>
    </table>
    <div class="mb-3">
      <label for="tokens" class="form-label">Tokens per Glimpse</label>
      <input
        bind:value={payload.tokens_per_glimpse}
        type="range"
        class="form-range"
        min="102"
        max="7371"
        step="1"
        id="tokens"
        aria-describedby="tokensHelp"
      />

      <div class="row align-items-center">
        <div class="col">
          <div class="input-group">
            <div class="input-group-text">Tokens</div>
            <input value={payload.tokens_per_glimpse} type="text" readonly class="form-control" />
          </div>
        </div>
        <div class="col">
          <div class="input-group">
            <div class="input-group-text">Glimpses</div>
            <input
              value={Presenter.number(
                Math.ceil(
                  ((payload.intersections ? 2 : 1) * parseFloat(estimationsOverview.tokens)) /
                    parseFloat(payload.tokens_per_glimpse)
                ),
                0,
                0
              )}
              type="text"
              readonly
              class="form-control"
            />
          </div>
        </div>
        <div class="col">
          <div class="input-group">
            <div class="input-group-text">GPT 3.5</div>
            <input
              value={Presenter.percent(parseFloat(payload.tokens_per_glimpse) / 4096.0, 0, 0)}
              type="text"
              readonly
              class={`form-control ${
                parseFloat(payload.tokens_per_glimpse) / 4096.0 > 0.9
                  ? 'text-danger-emphasis border-danger'
                  : ''
              }`}
            />
          </div>
        </div>
        <div class="col">
          <div class="input-group">
            <div class="input-group-text">Ada 2</div>
            <input
              value={Presenter.percent(parseFloat(payload.tokens_per_glimpse) / 8191.0, 0, 0)}
              type="text"
              readonly
              class="form-control"
            />
          </div>
        </div>
      </div>

      <div id="tokensHelp" class="form-text">
        A glimpse is a small piece of knowledge that we can use as a hint to help ChatGPT provide
        better answers or for searches. It's not possible to store the entire content of a knowledge
        in a single chunk. ChatGPT 3.5 can handle a maximum of 4,096 tokens for the entire chat
        history, while Ada Embeddings supports up to 8,191 tokens. If you want to use glimpses in
        chat conversations, it's recommended that you keep them within a fraction of the chat
        history limit to avoid breaking a dialogue.
      </div>
    </div>

    <div class="mb-3">
      <label for="models" class="form-label">Model</label>
      <select bind:value={payload.model} class="form-select" aria-label="models">
        {#each models as model}
          <option value={model.id}>{model.id} | {format(model.created_at)}</option>
        {/each}
      </select>
    </div>

    <div class="form-check">
      <input
        bind:checked={payload.intersections}
        class="form-check-input"
        type="checkbox"
        value=""
        id="intersectionsCheck"
      />
      <label class="form-check-label" for="intersectionsCheck"> Intersections </label>
      <div id="intersectionsCheck" class="form-text">
        Intersections generate additional glimpses, helping to circumvent the issue of "content
        precisely located at the junction of the divided sections." This approach may yield improved
        results, but it also doubles your costs.
      </div>
    </div>

    <div class="actions text-center">
      <button type="submit" class="btn btn-danger"> Yes, spend my money and upload. </button>
    </div>
  </form>
{:else}
  {state}
{/if}

<style>
  .actions {
    padding-top: 1em;
    padding-bottom: 0.6em;
  }

  .loading {
    padding: 2em;
    text-align: center;
  }

  .loading p {
    margin-top: 2em;
  }

  .state {
    text-align: center;
  }

  .state i {
    font-size: 2em;
  }

  .state p {
    padding-top: 1em;
  }
</style>
