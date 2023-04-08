<script>
  export let state;
  export let message = undefined;
</script>

<div class="state">
  {#if state === 'loading'}
    <div class="loading">
      <div class="spinner-border text-info-emphasis" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>

      <p>
        {#if message}
          {message}
        {:else}
          Loading, please wait...
        {/if}
      </p>
    </div>
  {:else if state === 'error'}
    <div class="state">
      <i class="bi bi-emoji-frown text-danger" />
      <p class="text-danger-emphasis">
        {#if message}
          {message}
        {:else}
          Something went wrong.
        {/if}
      </p>
    </div>
  {:else if state === 'success'}
    <div class="state">
      <i class="bi bi-check-circle-fill text-success" />
      <p class="text-success-emphasis">
        {#if message}
          {message}
        {:else}
          Success! Everything went smoothly.
        {/if}
      </p>
    </div>
  {/if}
</div>

<style>
  .loading {
    padding-top: 0.8em;
  }
  .loading p {
    margin-top: 1em;
  }

  .state {
    text-align: center;
    padding-top: 0.8em;
  }

  .state i {
    font-size: 2em;
  }

  .state p {
    padding-top: 1em;
  }
</style>
