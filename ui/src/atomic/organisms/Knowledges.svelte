<script>
  import Upload from './knowledges/Upload.svelte';
  import List from './knowledges/List.svelte';
  import Search from './knowledges/Search.svelte';

  let at = new Date();

  const callback = () => {
    at = new Date();
  };

  export let scope;
</script>

<div class="upload">
  <Upload {scope} {callback} />
</div>

<List {scope} {at} />

<div class="search">
  <Search {scope} />
</div>

<style>
  .search {
    margin-top: 2em;
  }

  .upload {
    margin-bottom: 2em;
  }
</style>
