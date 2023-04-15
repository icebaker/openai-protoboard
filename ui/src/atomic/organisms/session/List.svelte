<script>
  import { onMount } from 'svelte';

  import Modal from '../../templates/Modal.svelte';

  import Protoboard from '../../../components/protoboard.js';
  import TimeAtom from '../../atoms/Time.svelte';
  import EmptyAtom from '../../atoms/Empty.svelte';
  import StateAtom from '../../atoms/State.svelte';
  import Delete from './Delete.svelte';

  export let at;

  let state = 'loading';
  let sessions = undefined;

  const load = async () => {
    const result = (await Protoboard.get('/sessions'));

    if(result['success']) {
      sessions = result['success'];
      state = 'success';
    } else {
      state = 'error';
    }
  };

  let modalElement = undefined;

  const openDeleteModal = (session) => {
    if (modalElement) modalElement.open({ at: new Date(), session: session });
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
  {:else if sessions.length === 0}
    <EmptyAtom />
  {:else}
    <table class="table">
      <thead>
        <tr>
          <th scope="col" width="1" class="text-nowrap">Created At</th>
          <th scope="col" width="1">ID</th>
          <th scope="col">Name</th>
          <th scope="col" width="1" />
          <th scope="col" width="1" />
        </tr>
      </thead>
      <tbody>
        {#each sessions as session}
          <tr>
            <td class="text-nowrap"><TimeAtom at={session.created_at} /></td>
            <td><code>{session.id}</code></td>
            <td>
              {#if session.name}
                {session.name}
              {:else}
                -
              {/if}
            </td>
            <td>
              <a href={`/sessions/${session.id}`} class="btn btn-sm btn-outline-info">
                <i class="bi bi-arrow-right-circle-fill" />
              </a>
            </td>
            <td>
              <button
                on:click={openDeleteModal(session)}
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
    <Delete at={data.at} session={data.session} callback={load} />
  {/if}
</Modal>
