<script>
  import Modal from '../templates/Modal.svelte';
  import Create from './chats/Create.svelte';
  import List from './chats/List.svelte';
  import Chat from './Chat.svelte';

  export let id = undefined;

  export let scope;

  let at = new Date();

  let modalElement = undefined;

  const callback = () => {
    at = new Date();
  };

  const openModal = () => {
    if (modalElement) modalElement.open({ at: new Date() });
  };
</script>

<div>
  <div class="actions">
    <button on:click={openModal} type="button" class="btn btn-primary">New Chat</button>
  </div>

  <List {scope} {at} />

  {#if id}
    <Chat {id} />
  {/if}
</div>

<Modal bind:this={modalElement} size="md" title="New Chat" let:data>
  <Create at={data} {scope} {callback} />
</Modal>

<style>
  .actions {
    text-align: center;
    margin-bottom: 2em;
  }
</style>
