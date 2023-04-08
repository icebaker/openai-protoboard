<script>
  import Session from '../../../atomic/pages/Session.svelte';

  import { page } from '$app/stores';

  let id;
  $: {
    id = $page.params.sessionId;
  }
</script>

<Session {id} />
