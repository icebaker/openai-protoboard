<script>
  import SessionContainer from '../organisms/session/Container.svelte';
  import Knowledges from '../organisms/Knowledges.svelte';
  import Chats from '../organisms/Chats.svelte';

  export let id;
  export let chatId = undefined;

  const layout = 'columns';
</script>

<h1>Session</h1>

<div class="session">
  <SessionContainer {id} let:session>
    <div class="overview">
      {#if layout === 'columns'}
        <div class="row">
          <div class="col-7">
            <Chats {layout} scope={session.id} id={chatId} />
          </div>
          <div class="col-5">
            <Knowledges scope={session.id} />
          </div>
        </div>
      {:else if layout === 'tabs'}
        <ul class="nav nav-tabs" id="sessionTab" role="tablist">
          <li class="nav-item" role="presentation">
            <button
              class="nav-link active"
              id="chat-completions-tab"
              data-bs-toggle="tab"
              data-bs-target="#chat-completions-tab-pane"
              type="button"
              role="tab"
              aria-controls="chat-completions-tab-pane"
              aria-selected="true">Chat & Completions</button
            >
          </li>
          <li class="nav-item" role="presentation">
            <button
              class="nav-link"
              id="knowledge-tab"
              data-bs-toggle="tab"
              data-bs-target="#knowledge-tab-pane"
              type="button"
              role="tab"
              aria-controls="knowledge-tab-pane"
              aria-selected="false">Knowledge</button
            >
          </li>
        </ul>
        <div class="tab-content" id="sessionTabContent">
          <div
            class="tab-pane fade show active"
            id="chat-completions-tab-pane"
            role="tabpanel"
            aria-labelledby="chat-completions-tab"
            tabindex="0"
          >
            <Chats scope={session.id} id={chatId} />
          </div>
          <div
            class="tab-pane fade"
            id="knowledge-tab-pane"
            role="tabpanel"
            aria-labelledby="knowledge-tab"
            tabindex="0"
          >
            <Knowledges scope={session.id} />
          </div>
        </div>
      {/if}
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

  .tab-content {
    padding-top: 2em;
  }
</style>
