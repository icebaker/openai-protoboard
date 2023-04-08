<script>
  import Protoboard from '../../../components/protoboard.js';

  export let chat;
  export let updateHistory;

  let state = 'ready';
  let value = '';
  let textAreaElement = undefined;

  let errorMessage = undefined;

  const sendMessage = async (message) => {
    errorMessage = undefined;

    state = 'loading';

    const updatedChat = (await Protoboard.sendMessage(chat.id, message))['success'];

    if (updatedChat['error']) {
      state = 'error';
      errorMessage = updatedChat['error']['message'];
    } else if (!updatedChat) {
      state = 'error';
    } else {
      state = 'ready';
      updateHistory(updatedChat.chat.history);
    }
  };

  const handleEnterKey = async (event) => {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();

      const message = `${value}`;

      value = value.replace(/(\r\n|\n|\r)/gm, '');
      textAreaElement.value = value;
      value = '';

      await sendMessage(message);
    }
  };
</script>

<div class="form-floating">
  <textarea
    bind:this={textAreaElement}
    on:keydown={handleEnterKey}
    bind:value
    disabled={state === 'loading'}
    class="form-control"
    placeholder="send a message here"
    id="floatingTextarea"
  />
  <label for="floatingTextarea">Send a message...</label>
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
</style>
