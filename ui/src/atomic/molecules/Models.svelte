<script>
  import { onMount } from 'svelte';

  import Protoboard from '../../components/protoboard.js';
  import TimeAtom from '../atoms/Time.svelte';

  let state = 'loading';
  let models = undefined;

  const load = async () => {
    models = (await Protoboard.models())['success'];

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
        </tr>
      </thead>
      <tbody>
        {#each models as model}
          <tr>
            <td><code>{model.id}</code></td>
            <td>{model.owner}</td>
            <td><TimeAtom at={model.created_at} /></td>
            <td>
              <button type="button" class="btn btn-sm btn-outline-success">
                <i class="bi bi-plus-circle" />
              </button>
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  {/if}
</div>
