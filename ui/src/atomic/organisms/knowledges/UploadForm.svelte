<script>
  import { onMount } from 'svelte';

  import { nanoid } from 'nanoid';

  import Presenter from '../../../helpers/presenter.js';
  import Protoboard from '../../../components/protoboard.js';

  export let dragEvent;
  export let at;

  export let scope = undefined;
  export let callback;
  let files = undefined;
  let payload = undefined;

  let state = 'waiting';

  let previousAt = null;

  let estimations = {};
  let estimationsOverview = null;

  const prepareForm = async () => {
    state = 'estimating';
    previousAt = at;
    estimations = {};
    estimationsOverview = null;
    files = dragEvent.dataTransfer.files;
    await estimateTokens();
  };

  const estimateTokens = async () => {
    const promises = [];

    for (let i = 0; i < files.length; i++) {
      const file = files[i];
      const promise = Protoboard.estimateTokens(file, i);
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
      const promise = Protoboard.uploadKnowledge(scope, file);
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
              {Presenter.number(estimateFor(i).tokens)}
            </td>
            <td class="text-center text-danger-emphasis">
              {Presenter.money(estimateFor(i).dollars, undefined, 10)}
            </td>
          </tr>
        {/each}
        <tr>
          <td class="text-end">
            <em> Estimated Total </em>
          </td>
          <td class="text-center text-warning">
            <strong>
              {Presenter.number(estimationsOverview.tokens)}
            </strong>
          </td>
          <td class="text-center text-danger">
            <strong>
              {Presenter.money(estimationsOverview.dollars, undefined, 10)}
            </strong>
          </td>
        </tr>
      </tbody>
    </table>
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
