<script>
  import { onMount } from 'svelte';

  import Recorder from './Recorder.svelte';

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

  const submitContent = async (clear) => {
    const content = `${value}`;

    if(clear === undefined || clear === 'before') {
      value = value.replace(/(\r\n|\n|\r)/gm, '');
      element.value = value;
      value = '';

      resizeInput();
    }

    await dispatchContent(content);

    if(clear === undefined || clear === 'after') {
      value = value.replace(/(\r\n|\n|\r)/gm, '');
      element.value = value;
      value = '';
    }

    resizeInput();

    setTimeout(() => element.focus(), 200);

  }

  const onKeyDown = async (event) => {
    resizeInput();
    if (handler && event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();
      await submitContent();
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

  const onRecording = () => {
    disabled = true;
    state = 'loading';
  }

  const onRecordingError = (error) => {
    state = 'waiting';
    disabled = false;
  }

  const onTranscribed = async (result, autoSubmit) => {
    value = result['success']['text'];
    if(autoSubmit) {
      await submitContent('after');
    } else {
      disabled = false;
      resizeInput();
      setTimeout(() => element.focus(), 200);
    }
    state = 'waiting';
  }
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

<div class="recorder">
  <Recorder {onRecording} {onTranscribed} onError={onRecordingError} />
</div>

<style>
  .recorder {
    margin-top: 0em;
  }
  .input-area {
    overflow-y: hidden;
  }
</style>
