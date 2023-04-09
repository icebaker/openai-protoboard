<script>
  import { onMount } from 'svelte';

  export let disabled = false;
  export let label = 'Send a content...';
  export let placeholder = 'send a content here';
  export let handler = undefined;

  let state = 'waiting';
  export let value = '';
  let element = undefined;

  const dispatchContent = async (content) => {
    if (handler) await handler(content);
  };

  const resizeInput = () => {
    element.style.height = 'auto';
    const minHeight = 82;

    let newHeight = element.scrollHeight + 10;

    if (newHeight < minHeight) {
      newHeight = minHeight;
    }

    element.style.height = newHeight + 'px';
  };

  onMount(() => {
    const previousValue = `${value}`;
    resizeInput();
  });

  const onKeyUp = (event) => {
    resizeInput();
  };

  const onKeyDown = async (event) => {
    resizeInput();
    if (handler && event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();

      const content = `${value}`;

      value = value.replace(/(\r\n|\n|\r)/gm, '');
      element.value = value;
      value = '';

      resizeInput();

      await dispatchContent(content);

      resizeInput();

      setTimeout(() => element.focus(), 200);
    }
  };

  const handleDragOver = (event) => {
    state = 'over';
    event.preventDefault();
  };

  const handleDragLeave = (event) => {
    state = 'waiting';
  };

  const handleDrop = (event) => {
    state = 'loading';
    event.preventDefault();

    const file = event.dataTransfer.files[0];

    const fileReader = new FileReader();

    fileReader.onload = (e) => {
      const fileContent = e.target.result;
      value = fileContent;
      setTimeout(() => {
        resizeInput();
      }, 0);
    };

    fileReader.readAsText(file);
  };

  const dragClass = () => {
    if (state === 'over') {
      return 'form-control input-area border-success';
    } else if (state === 'over') {
      return 'form-control input-area border-warning';
    } else {
      return 'form-control input-area';
    }
  };
</script>

<div class="form-floating">
  <textarea
    bind:this={element}
    on:keydown={onKeyDown}
    on:keyup={onKeyUp}
    bind:value
    on:drop={handleDrop}
    on:dragover={handleDragOver}
    on:dragleave={handleDragLeave}
    {disabled}
    class={dragClass(state)}
    {placeholder}
    id="floatingTextarea"
  />
  <label for="floatingTextarea">{label}</label>
</div>

<style>
  .input-area {
    overflow-y: hidden;
  }
</style>
