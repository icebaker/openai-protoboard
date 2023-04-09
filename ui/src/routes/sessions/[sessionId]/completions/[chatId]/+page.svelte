<script>
  import Session from '../../../../../atomic/pages/Session.svelte';

  import { page } from '$app/stores';

  let sessionId;
  let chatId;

  $: {
    sessionId = $page.params.sessionId;
    chatId = $page.params.chatId;
  }
</script>

<Session id={sessionId} {chatId} />
