<script>
  import Modal from '../templates/Modal.svelte';
  import Create from './chats/Create.svelte';
  import List from './chats/List.svelte';
  import Chat from './Chat.svelte';

  export let id = undefined;

  export let scope;
  export let layout;

  let at = new Date();

  let modalElement = undefined;
  let modalTitle = undefined;

  const callback = () => {
    at = new Date();
  };

  const openModal = (kind) => {
    if (kind === 'chat') {
      modalTitle = 'New Chat';
    } else {
      modalTitle = 'New Completion';
    }
    if (modalElement) modalElement.open({ at: new Date(), kind: kind });
  };
</script>

<div>
  {#if layout === 'columns'}
    <div class="actions">
      <button
        on:click={() => {
          openModal('chat');
        }}
        type="button"
        class="btn btn-primary"
      >
        New Chat
      </button>

      <button
        on:click={() => {
          openModal('completion');
        }}
        type="button"
        class="btn btn-success"
      >
        New Completion
      </button>
    </div>
    <List {scope} {at} />

    {#if id}
      <Chat {id} />
    {/if}
  {:else}
    <div class="row">
      <div class="col">
        {#if id}
          <Chat {id} />
        {/if}
      </div>
      <div class="col-5">
        <div class="actions">
          <button
            on:click={() => {
              openModal('chat');
            }}
            type="button"
            class="btn btn-primary"
          >
            New Chat
          </button>

          <button
            on:click={() => {
              openModal('completion');
            }}
            type="button"
            class="btn btn-success"
          >
            New Completion
          </button>
        </div>
        <List {scope} {at} />
      </div>
    </div>
  {/if}
</div>

<Modal bind:this={modalElement} size="md" title={modalTitle} let:data>
  {#if data}
    <Create at={data.at} kind={data.kind} {scope} {callback} />
  {/if}
</Modal>

<style>
  .actions {
    text-align: center;
    margin-top: 1.1em;
    margin-bottom: 2em;
  }

  .actions button {
    margin: 0 0.3em;
  }
</style>
