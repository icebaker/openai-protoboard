<script>
  import { onMount } from 'svelte';

  import Modal from '../../templates/Modal.svelte';
  import Delete from './Delete.svelte';
  import Protoboard from '../../../components/protoboard.js';
  import TimeAtom from '../../atoms/Time.svelte';
  import StateAtom from '../../atoms/State.svelte';
  import EmptyAtom from '../../atoms/Empty.svelte';

  export let at;
  export let scope;

  let state = 'loading';
  let chats = [];

  const load = async () => {
    const result = await Protoboard.get('/chats', { scope: scope });

    if (result['success']) {
      chats = result['success'];
      state = 'success';
    } else {
      state = 'error';
    }
  };

  let modalElement = undefined;

  const openDeleteModal = (chat) => {
    if (modalElement) modalElement.open({ at: new Date(), chat: chat });
  };

  let isMounted = false;

  onMount(async () => {
    isMounted = true;
    await load();
  });

  $: {
    if (isMounted && at) load();
  }
</script>

<div>
  {#if state === 'loading' || state === 'error'}
    <StateAtom {state} />
  {:else if chats.length === 0}
    <EmptyAtom />
  {:else}
    <table class="table">
      <thead>
        <tr>
          <th scope="col">Description</th>
          <th scope="col">Created At</th>
          <th scope="col" width="1" />
          <th scope="col" width="1" />
        </tr>
      </thead>
      <tbody>
        {#each chats as chat}
          <tr>
            <td>
              {#if chat.description}
                {chat.description}
              {:else}
                -
              {/if}
            </td>
            <td><TimeAtom at={chat.created_at} /></td>
            <td>
              {#if chat.kind === 'completion'}
                <a
                  href={`/sessions/${chat.scope}/completions/${chat.id}`}
                  class="btn btn-sm btn-outline-success"
                >
                  <i class="bi bi-terminal" />
                </a>
              {:else}
                <a
                  href={`/sessions/${chat.scope}/chats/${chat.id}`}
                  class="btn btn-sm btn-outline-info"
                >
                  <i class="bi bi-chat-dots" />
                </a>
              {/if}
            </td>
            <td>
              <button
                on:click={openDeleteModal(chat)}
                type="button"
                class="btn btn-sm btn-outline-danger"
              >
                <i class="bi bi-trash" />
              </button>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  {/if}
</div>

<Modal bind:this={modalElement} title="Delete Session" let:data>
  {#if data}
    <Delete at={data.at} chat={data.chat} callback={load} />
  {/if}
</Modal>
