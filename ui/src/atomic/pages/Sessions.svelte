<script>
  import Modal from '../templates/Modal.svelte';
  import Create from '../organisms/session/Create.svelte';
  import List from '../organisms/session/List.svelte';

  let modalElement = undefined;

  let at = new Date();

  const callback = () => {
    at = new Date();
  };

  const openModal = () => {
    if (modalElement) modalElement.open({ at: new Date() });
  };
</script>

<h1>Sessions</h1>

<p>
  Sessions create an isolated space that enables you to upload custom knowledge, engage in multiple
  chats leveraging this knowledge, and explore it further through smart searches. You can have as
  many sessions as you want.
</p>

<button on:click={openModal} type="button" class="btn btn-primary">Create Session</button>

<br /><br />

<List {at} />

<Modal bind:this={modalElement} size="md" title="Create Session" let:data>
  <Create at={data} {callback} />
</Modal>
