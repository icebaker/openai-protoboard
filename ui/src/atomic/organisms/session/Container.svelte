<script>
  import { onMount } from 'svelte';

  import Protoboard from '../../../components/protoboard.js';

  import TimeAtom from '../../atoms/Time.svelte';
  import StateAtom from '../../atoms/State.svelte';

  import Header from '../../molecules/session/Header.svelte';

  export let id;

  let state = 'loading';
  let session = undefined;

  const load = async () => {
    const result = await Protoboard.get(`/sessions/${id}`);

    if (result['success']) {
      session = result['success'];
      state = 'success';
    } else {
      state = 'error';
    }
  };

  let isMounted = false;

  onMount(async () => {
    isMounted = true;
    await load();
  });

  $: {
    if (isMounted && id) load();
  }
</script>

<div>
  {#if state !== 'success'}
    <StateAtom {state} />
  {:else}
    <Header {session} />

    <slot {session} />
  {/if}
</div>
