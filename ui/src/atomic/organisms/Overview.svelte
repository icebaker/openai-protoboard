<script>
  import Models from '../molecules/Models.svelte';
  import Chats from '../molecules/Chats.svelte';
  import Chat from './Chat.svelte';

  export let chatId = undefined;
</script>

<div class="row">
  <div class="col-7">
    <Chats {chatId} />
  </div>
  <div class="col-5">
    <Models />
  </div>
</div>
{#if chatId}
  <Chat id={chatId} />
{/if}
