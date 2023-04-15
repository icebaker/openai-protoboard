<script>
  import { onMount } from 'svelte';
  import { format } from 'timeago.js';

  import { nanoid } from 'nanoid';

  import Presenter from '../../../helpers/presenter.js';
  import Protoboard from '../../../components/protoboard.js';
  import Content from '../../molecules/Content.svelte';

  export let knowledge;
  export let at;
  export let scope;
  export let callback;

  let state = 'waiting';

  let previousAt = null;
  let protoboardAPI = undefined;

  const payloadTemplate = {
    tokens: 3086,
    model: 'gpt-3.5-turbo',
    scope: scope,
    translate: false,
    language: '',
    knowledge: null
  };

  let payload = JSON.parse(JSON.stringify(payloadTemplate));

  let models;

  const prepareForm = async () => {
    state = 'waiting';
    payload = JSON.parse(JSON.stringify(payloadTemplate));
    payload.knowledge = knowledge;
    models = (await Protoboard.get('/models', { purpose: 'chat' }))['success'];
    state = 'prepare';
  };

  let summary = null;
  const submitForm = async () => {
    state = 'loading';

    payload.tokens = parseInt(payload.tokens, 10);

    const result = await Protoboard.post('/knowledges/summaries', payload);

    if (result['success']) {
      summary = result['success'];
      state = 'success';
    } else {
      state = 'error';
    }

    if (callback) callback();
  };

  let isMounted = false;

  onMount(async () => {
    isMounted = true;
    protoboardAPI = await Protoboard.api();
    prepareForm();
  });

  $: {
    if (isMounted && at !== previousAt) prepareForm();
  }

  const estimateFor = (index) => {
    return estimations[index];
  };

  const downloadLink = (knowledge) => {
    return Protoboard.download_link(protoboardAPI, knowledge);
  };
</script>

{#if state === 'loading' || state === 'waiting'}
  <div class="loading">
    <div class="spinner-border text-info-emphasis" role="status">
      <span class="visually-hidden">Loading...</span>
    </div>

    {#if state === 'loading'}
      <p>
        Summarizing. This may take a while.
        <br />
        Please be patient.
      </p>
    {/if}
  </div>
{:else if state === 'error'}
  <div class="state">
    <i class="bi bi-check-circle-fill text-danger" />
    <p>
      Oops! There was an issue summarizing the content.
      <br />
      Please give it another try.
    </p>
  </div>
{:else if state === 'success'}
  <div class="state">
    <i class="bi bi-check-circle-fill text-success" />
    <p>Summary created!</p>

    <div class="text-start">
      <Content content={summary} direction="start" />
    </div>
  </div>
{:else if state === 'prepare'}
  <form on:submit|preventDefault={submitForm}>
    <div class="mb-3">
      <table class="table">
        <thead>
          <tr>
            <th scope="col">Knowledge</th>
            <th scope="col" width="1" class="text-center">Glimpses</th>
            <th scope="col" width="1" class="text-center">Tokens</th>
            <th scope="col" width="1" class="text-center" />
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>
              <i class="bi bi-file-binary text-warning-emphasis" />
              <a
                href={downloadLink(knowledge)}
                class="download font-monospace d-inline-block text-truncate"
                style="max-width: 17em;"
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
          </tr></tbody
        >
      </table>
    </div>
    <br />
    <div class="mb-3">
      <label for="tokens" class="form-label">Tokens</label>
      <input
        bind:value={payload.tokens}
        type="range"
        class="form-range"
        min="102"
        max="3686"
        step="1"
        id="tokens"
        aria-describedby="tokensHelp"
      />

      <div class="row align-items-center">
        <div class="col">
          <div class="input-group">
            <div class="input-group-text">Tokens</div>
            <input
              value={Presenter.number(payload.tokens)}
              type="text"
              readonly
              class="form-control"
            />
          </div>
        </div>
        <div class="col">
          <div class="input-group">
            <div class="input-group-text">Words</div>
            <input
              value={Presenter.number(parseInt(payload.tokens * (3.0 / 4.0), 10))}
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
              value={Presenter.percent(parseFloat(payload.tokens) / 4096.0, 0, 0)}
              type="text"
              readonly
              class={`form-control ${
                parseFloat(payload.tokens) / 4096.0 > 0.9
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
              value={Presenter.percent(parseFloat(payload.tokens) / 8191.0, 0, 0)}
              type="text"
              readonly
              class="form-control"
            />
          </div>
        </div>
      </div>

      <div id="tokensHelp" class="form-text">
        Chat GPT tokens are text units the AI processes to generate and understand language.
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

    <div class="row align-items-center">
      <div class="col">
        <div class="mb-3">
          <label for="translation" class="form-label">Language</label>
          <select bind:value={payload.translate} class="form-select" aria-label="translation">
            <option value={false}>Keep the language of the source content</option>
            <option value={true}>Translate to another language</option>
          </select>
        </div>
      </div>
      <div class="col">
        <div class="mb-3">
          <label for="language" class="form-label">Desired Langauge</label>
          {#if payload.translate}
            <input
              bind:value={payload.language}
              disabled={!payload.translate}
              placeholder="ja-JP, spanish, en-US, french..."
              type="text"
              class="form-control"
            />
          {:else}
            <input value="-" type="text" class="form-control" disabled />
          {/if}
        </div>
      </div>
    </div>

    <div class="alert alert-danger text-center" role="alert">
      Summarizing is a beta feature. The results may be far from perfect. If you are trying to
      summarize large content like an entire book, it will be very slow and somewhat expensive.
    </div>

    <div class="actions text-center">
      <button type="submit" class="btn btn-danger"
        >I want to try anyway, go ahead and summarize.</button
      >
    </div>
  </form>
{:else}
  {state}
{/if}

<style>
  .actions {
    padding-top: 0;
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

  .download {
    vertical-align: middle;
  }
</style>
