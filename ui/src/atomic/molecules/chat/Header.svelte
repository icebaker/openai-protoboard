<script>
  import TimeAtom from '../../atoms/Time.svelte';

  export let chat;
</script>

<table class="table">
  <tbody>
    <tr>
      <th scope="col" class="text-end">Description</th>
      <td>
        {#if chat.description}
          {chat.description}
        {:else}
          -
        {/if}
      </td>
      <th scope="col" class="text-end">Created At</th>
      <td><TimeAtom at={chat.created_at} /></td>
    </tr>
  </tbody>
</table>
