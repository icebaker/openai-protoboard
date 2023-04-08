<script>
  export let message = undefined;
</script>

<div>
  <p class="text-secondary">
    {#if message}
      {message}
    {:else}
      Start by creating something new here.
    {/if}
  </p>
</div>

<style>
  p {
    text-align: center;
    font-size: 1.4em;
    padding: 2em 0;
  }
</style>
