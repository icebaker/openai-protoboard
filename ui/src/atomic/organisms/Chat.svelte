<script>
  import { onMount } from 'svelte';

  import Protoboard from '../../components/protoboard.js';
  import TimeAtom from '../atoms/Time.svelte';
  import ChatHeader from '../molecules/chat/Header.svelte';
  import ChatHistory from '../molecules/chat/History.svelte';
  import ChatInput from '../molecules/chat/Input.svelte';

  let state = 'loading';
  export let id;
  let chat = undefined;

  const load = async () => {
    state = 'loading';

    const response = await Protoboard.get(`/chats/${id}`, { verbose: true });

    if (response['error']) {
      state = 'error';
    } else {
      chat = response['success'];
      state = 'success';
    }
  };

  let at = new Date();

  const updateHistory = (history) => {
    chat.history = history;
    at = new Date();
  };

  let isMounted = false;

  onMount(() => {
    isMounted = true;
  });

  $: {
    if (isMounted && id) load();
  }
</script>

<div class="chat">
  {#if state === 'loading'}
    <div class="loading">
      <div class="spinner-border" role="status">
        <span class="visually-hidden">Loading...</span>
      </div>
    </div>
  {:else if state === 'error'}
    <div class="alert alert-danger text-center" role="alert">
      {id} - error
    </div>
  {:else}
    <div>
      <ChatHeader {chat} />
      <div class="prompt">
        <div class="chat-input">
          <ChatInput {chat} {updateHistory} />
        </div>
        <ChatHistory {at} {chat} />
      </div>
    </div>
  {/if}
</div>

<style>
  .chat-input {
    margin-bottom: 1em;
  }

  .loading {
    text-align: center;
  }

  .prompt {
    margin: 2em 1em 0 1em;
  }

  .chat {
    margin-top: 2em;
  }
</style>
