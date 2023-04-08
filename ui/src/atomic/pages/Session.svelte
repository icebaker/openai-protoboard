<script>
  import SessionContainer from '../organisms/session/Container.svelte';
  import Knowledges from '../organisms/Knowledges.svelte';
  import Chats from '../organisms/Chats.svelte';

  export let id;
  export let chatId = undefined;
</script>

<h1>Session</h1>

<div class="session">
  <SessionContainer {id} let:session>
    <div class="overview">
      <div class="row">
        <div class="col-7">
          <Chats scope={session.id} id={chatId} />
        </div>
        <div class="col-5">
          <Knowledges scope={session.id} />
        </div>
      </div>
    </div>
  </SessionContainer>
</div>

<style>
  .session {
    margin: 2em 0;
  }

  .overview {
    margin: 2em 0 2em 0;
  }
</style>
