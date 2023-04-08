<script>
  import TimeAtom from '../../atoms/Time.svelte';
  import Content from '../Content.svelte';
  import Glimpse from '../Glimpse.svelte';
  import System from './System.svelte';

  export let chat;
  export let at;
</script>

<div class="chat-container">
  {#each chat.history as event}
    {#if event.glimpse}
      <div class="message border-bottom">
        <Glimpse glimpse={event.glimpse} />
      </div>
    {:else if event.input.message.role === 'system'}
      <div class="message border-bottom">
        <System {event} />
      </div>
    {:else}
      <div class="row message border-bottom">
        {#if event.input.message.role === 'user'}
          <div class="col" />
        {/if}
        <div
          class={`col-10 ${
            event.input.message.role === 'user' ? 'text-end' : 'text-info-emphasis'
          }`}
        >
          <div>
            <Content content={event.input.message.content} />
          </div>
        </div>
        {#if event.input.message.role !== 'user'}
          <div class="col" />
        {/if}
      </div>
    {/if}
  {/each}
</div>

<style>
  .chat-container {
    /*padding: 0 2em;*/
    /*overflow-y: scroll;
  overflow-x: hidden;*/
  }

  .message {
    padding: 1em 0 0 0;
  }
</style>
