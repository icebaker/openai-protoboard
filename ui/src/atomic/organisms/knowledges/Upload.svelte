<script>
  import Modal from '../../templates/Modal.svelte';
  import UploadForm from './UploadForm.svelte';

  export let callback = undefined;
  export let scope = undefined;
  let state = 'waiting';

  const handleDragOver = (event) => {
    state = 'over';
    event.preventDefault();
  };

  const handleDragLeave = (event) => {
    state = 'waiting';
  };

  let modalElement = undefined;

  const handleDrop = (event) => {
    state = 'uploading';
    event.preventDefault();

    if (modalElement) modalElement.open({ event: event, at: new Date() });
  };

  const dragClass = (state) => {
    const classes = ['drag-area', state];

    if (state === 'over') {
      classes.push('border-success');
    } else if (state === 'uploading') {
      classes.push('border-info');
    } else {
      classes.push('border-secondary');
    }

    return classes.join(' ');
  };

  let selectedFiles = null;

  const internalCallback = () => {
    state = 'waiting';
    selectedFiles = null;
    if (callback) callback();
  };

  let fileInputElement;

  const handleClick = () => {
    if (fileInputElement) fileInputElement.click();
  };
</script>

<input
  type="file"
  bind:this={fileInputElement}
  on:change={handleDrop}
  bind:files={selectedFiles}
  hidden
  multiple
/>

<div class="drag-container">
  <button
    class={dragClass(state)}
    on:click={handleClick}
    on:drop={handleDrop}
    on:dragover={handleDragOver}
    on:dragleave={handleDragLeave}
  >
    {#if state === 'uploading'}
      <div class="icon text-secondary">
        <i class="bi bi-hourglass-split" />
      </div>
    {:else}
      <div class="icon text-secondary">
        <i class="bi bi-upload" />
      </div>
    {/if}
  </button>
</div>

<Modal
  bind:this={modalElement}
  onComplete={internalCallback}
  size="lg"
  title="Upload Knowledge"
  let:data
>
  {#if data}
    <UploadForm event={data.event} at={data.at} {scope} callback={internalCallback} />
  {/if}
</Modal>

<style>
  .drag-container {
    /*width: 100%;*/
    /*height: 4em;*/
  }

  .drag-area {
    background: transparent;
    width: 100%;
    height: 100%;
    border: 2px dashed;
    text-align: center;
  }

  .drag-area .icon {
    padding: 0.4em 0;
  }

  .drag-area .icon i {
    font-size: 1.6em;
  }
</style>
