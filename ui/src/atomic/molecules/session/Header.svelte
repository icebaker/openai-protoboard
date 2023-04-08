<script>
  import TimeAtom from '../../atoms/Time.svelte';

  export let session;
</script>

<table class="table">
  <tbody>
    <tr>
      <th scope="col" class="text-end">Name</th>
      <td>
        {#if session.name}
          {session.name}
        {:else}
          -
        {/if}
      </td>
      <th scope="col" class="text-end">Created At</th>
      <td><TimeAtom at={session.created_at} /></td>
      <th scope="col" class="text-end">ID</th>
      <td><code>{session.id}</code></td>
    </tr>
  </tbody>
</table>
