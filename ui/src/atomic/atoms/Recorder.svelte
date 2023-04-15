<script>
  import { onMount } from 'svelte';
  import Protoboard from '../../components/protoboard.js';

  export let startRecordingAt = undefined;
  export let onRecording = undefined;
  export let onTranscribed = undefined;
  export let onError = undefined;
  export let autoSubmit = false;

  let hasError = false;
  let recorder;
  let stream;
  let RecordRTC;
  let recording = false;
  let secondsRecorded = 0;
  let intervalId;
  let audioURL = null;
  let audioElement;
  let playing = false;
  let audioContext;
  let analyser;
  let dataArray;
  let meter;
  let sending = false;

  let recordingButton = undefined;

  const loadRecordRTC = async () => {
    const module = await import('recordrtc');
    RecordRTC = module.default;
  };

  const toggleRecording = async () => {
    if (!recording) {
      await startRecording();
    } else {
      await stopRecording();
    }
    recording = !recording;
  };

  const startRecording = async () => {
    hasError = false;
    if (onRecording) onRecording();
    await loadRecordRTC();
    stream = await navigator.mediaDevices.getUserMedia({ audio: true });

    audioContext = new AudioContext();
    analyser = audioContext.createAnalyser();
    dataArray = new Uint8Array(analyser.frequencyBinCount);

    const source = audioContext.createMediaStreamSource(stream);
    source.connect(analyser);

    requestAnimationFrame(updateMeter);

    recorder = new RecordRTC(stream, { type: 'audio', mimeType: 'audio/webm', disableLogs: true });
    recorder.startRecording();

    intervalId = setInterval(() => {
      secondsRecorded++;
    }, 1000);
  };

  const updateMeter = () => {
    if (meter) {
      analyser.getByteFrequencyData(dataArray);
      let sum = 0;

      for (let i = 0; i < dataArray.length; i++) {
        sum += dataArray[i];
      }

      const average = sum / dataArray.length;
      const sensitivity = 2;
      meter.value = average / sensitivity;
    }

    if (recording) {
      requestAnimationFrame(updateMeter);
    }
  };

  const stopRecording = async () => {
    clearInterval(intervalId);

    recorder.stopRecording(async () => {
      let blob = recorder.getBlob();
      audioURL = window.URL.createObjectURL(blob);

      recorder.destroy();
      recorder = null;

      stream.getTracks().forEach((track) => track.stop());
      audioContext.close();

      sendAudioToEndpoint(blob);
    });

    secondsRecorded = 0;
  };

  const togglePlayback = () => {
    if (audioElement.paused) {
      audioElement.play();
      playing = true;
    } else {
      audioElement.pause();
      playing = false;
    }
  };

  let errorMessage = null;

  const sendAudioToEndpoint = async (blob) => {
    sending = true;
    try {
      const response = await Protoboard.audioToText(blob);

      if (onTranscribed) await onTranscribed(response, autoSubmit);
    } catch (error) {
      hasError = true;
      errorMessage = error.message;
      if (onError) onError(error);
    }
    sending = false;

    setTimeout(() => {
      if (autoSubmit) recordingButton.focus();
    }, 0);
  };

  let recordingButtonFocused = false;
  let checkboxFocused = false;

  const handleRecordingButtonFocus = () => {
    recordingButtonFocused = true;
  };

  const handleRecordingButtonBlur = () => {
    recordingButtonFocused = false;
  };

  const handleCheckboxFocus = () => {
    checkboxFocused = true;
  };

  const handleCheckboxBlur = () => {
    checkboxFocused = false;
  };

  const startRecordingShortcut = () => {
    toggleRecording();
  };

  const handleKeyDown = (event) => {
    if (event.key === 's') {
      event.preventDefault();
      toggleRecording();
    }
  };

  let isMounted = false;

  onMount(() => {
    isMounted = true;
  });

  $: {
    if (isMounted && startRecordingAt) startRecordingShortcut();
  }
</script>

<button
  bind:this={recordingButton}
  class="btn btn-sm {recording ? 'btn-danger' : 'btn-primary'}"
  on:click={toggleRecording}
  disabled={sending}
  tabindex="0"
  on:keydown={handleKeyDown}
  on:focus={handleRecordingButtonFocus}
  on:blur={handleRecordingButtonBlur}
>
  <i class="bi {recording ? 'bi-stop-fill' : 'bi-mic-fill'}" />
</button>

<div class="form-check mt-3 auto-submit">
  <label class="form-check-label">
    <input
      on:keydown={handleKeyDown}
      bind:checked={autoSubmit}
      on:focus={handleCheckboxFocus}
      on:blur={handleCheckboxBlur}
      class="form-check-input"
      type="checkbox"
    />
    Auto-submit
  </label>
</div>

{#if recording}
  <meter
    bind:this={meter}
    min="0"
    max="255"
    class="mx-3"
    style="height: 1.5rem; vertical-align: middle;"
  />
{/if}

{#if !recording && audioURL}
  <button class="btn btn-sm btn-success ms-3" on:click={togglePlayback}>
    <i class="bi {playing ? 'bi-pause-fill' : 'bi-play-fill'}" />
  </button>

  {#if sending}
    <button class="loading btn btn-sm btn-secondary" type="button" disabled>
      <span class="spinner-grow spinner-grow-sm" role="status" aria-hidden="true" />
      <span class="visually-hidden">Loading...</span>
    </button>
  {/if}

  {#if hasError}
    <button class="btn btn-sm btn-danger error" disabled>
      <i class="bi bi-exclamation-triangle-fill" />
    </button>
  {/if}

  <audio
    src={audioURL}
    bind:this={audioElement}
    style="display: none;"
    on:ended={() => (playing = false)}
  />
{/if}

{#if autoSubmit && (recordingButtonFocused || checkboxFocused)}
  <span class="d-inline-block shortcut-text text-secondary">
    Press
    <button disabled type="button" class="btn btn-sm btn-outline-secondary">S</button>
    to start or finish recording.
  </span>
{/if}

<style>
  .loading {
    margin-left: 0.5em;
  }
  .auto-submit {
    display: inline-block;
    margin-left: 0.6em;
    margin-right: -0.3em;
  }
  .error {
    margin-left: 0.6em;
  }

  .loading .spinner-grow {
    margin-bottom: -0.1em;
  }

  .shortcut-text {
    margin-top: 1em;
    float: right;
    margin-right: 0.2em;
  }
</style>
