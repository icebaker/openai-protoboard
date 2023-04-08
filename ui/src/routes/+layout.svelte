<script>
  import Menu from '../atomic/organisms/Menu.svelte';
</script>

<div class="container">
  <Menu />
  <slot />
</div>

<style>
  .container {
    margin-top: 2em;
    margin-bottom: 8em;
  }
</style>
