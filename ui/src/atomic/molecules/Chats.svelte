<script>
  import { onMount } from 'svelte';

  import Protoboard from '../../components/protoboard.js';
  import TimeAtom from '../atoms/Time.svelte';

  export let chatId;

  let state = 'loading';
  let chats = undefined;

  const load = async () => {
    chats = (await Protoboard.chats())['success'];

    state = 'success';
  };

  onMount(async () => {
    await load();
  });
</script>

<div>
  {#if state === 'loading'}
    loading...
  {:else}
    <table class="table">
      <thead>
        <tr>
          <th scope="col">ID</th>
          <th scope="col">Created At</th>
          <th scope="col">Model</th>
          <th scope="col" width="1" />
          <th scope="col" width="1" />
        </tr>
      </thead>
      <tbody>
        {#each chats as chat}
          <tr>
            <td><code>{chat.id}</code></td>
            <td><TimeAtom at={chat.created_at} /></td>
            <td><code>{chat.model}</code></td>
            <td>
              <a href={`/chats/${chat.id}`} class="btn btn-sm btn-outline-info">
                <i class="bi bi-chat-dots" />
              </a>
            </td>
            <td>
              <a href="" class="btn btn-sm btn-outline-danger">
                <i class="bi bi-trash" />
              </a>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  {/if}
</div>
