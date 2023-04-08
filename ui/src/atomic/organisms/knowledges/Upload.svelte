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

  const internalCallback = () => {
    state = 'waiting';
    if (callback) callback();
  };
</script>

<div class="drag-container">
  <div
    class={dragClass(state)}
    on:drop={handleDrop}
    on:dragover={handleDragOver}
    on:dragleave={handleDragLeave}
  >
    {#if state === 'uploading'}
      <div class="icon">
        <i class="bi bi-hourglass-split" />
      </div>
    {:else}
      <div class="icon">
        <i class="bi bi-upload" />
      </div>
    {/if}
  </div>
</div>

<Modal
  bind:this={modalElement}
  onComplete={internalCallback}
  size="lg"
  title="Upload Knowledge"
  let:data
>
  {#if data}
    <UploadForm dragEvent={data.event} at={data.at} {scope} callback={internalCallback} />
  {/if}
</Modal>

<style>
  .drag-container {
    /*width: 100%;*/
    /*height: 4em;*/
  }

  .drag-area {
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
