<script>
import { onMount } from 'svelte';
import Protoboard from '../../components/protoboard.js';

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

const loadRecordRTC = async () => {
  const module = await import('recordrtc');
  RecordRTC = module.default;
}

const toggleRecording = async () => {
  if (!recording) {
    await startRecording();
  } else {
    await stopRecording();
  }
  recording = !recording;
}

const startRecording = async () => {
  hasError = false;
  if(onRecording) onRecording();
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
}

const updateMeter = () => {
  if(meter) {
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
}

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
}

const togglePlayback = () => {
  if (audioElement.paused) {
    audioElement.play();
    playing = true;
  } else {
    audioElement.pause();
    playing = false;
  }
}

let errorMessage = null;

const sendAudioToEndpoint = async (blob) => {
  sending = true;
  try {
    const response = (await Protoboard.audioToText(blob));

    if(onTranscribed) await onTranscribed(response, autoSubmit);
  } catch (error) {
    hasError = true;
    errorMessage = error.message;
    if(onError) onError(error);
  }
  sending = false;
}
</script>

<button
  class="btn btn-sm {recording ? 'btn-danger' : 'btn-primary'}"
  on:click="{toggleRecording}"
  disabled="{sending}"
>
  <i class="bi {recording ? 'bi-stop-fill' : 'bi-mic-fill'}"></i>
</button>

<div class="form-check mt-3 auto-submit">
  <label class="form-check-label">
    <input class="form-check-input" type="checkbox" bind:checked="{autoSubmit}">
    Auto-submit
  </label>
</div>

{#if recording}
  <meter bind:this="{meter}" min="0" max="255" class="mx-3" style="height: 1.5rem; vertical-align: middle;"></meter>
{/if}

{#if !recording && audioURL}
  <button class="btn btn-sm btn-success ms-3" on:click="{togglePlayback}">
    <i class="bi {playing ? 'bi-pause-fill' : 'bi-play-fill'}"></i>
  </button>

  {#if sending}
    <button class="loading btn btn-sm btn-secondary" type="button" disabled>
      <span class="spinner-grow spinner-grow-sm" role="status" aria-hidden="true"></span>
      <span class="visually-hidden">Loading...</span>
    </button>
  {/if}

  {#if hasError}
    <button
      class="btn btn-sm btn-danger error"
      disabled
    >
     <i class="bi bi-exclamation-triangle-fill"></i>
    </button>
  {/if}

  <audio
    src="{audioURL}"
    bind:this="{audioElement}"
    style="display: none;"
    on:ended="{() => playing = false}"
  ></audio>
{/if}

<style>
.loading {
  margin-left: .5em;
}
.auto-submit {
  display: inline-block;
  margin-left: .6em;
  margin-right: -.3em;
}
.error {
  margin-left:.6em;
}

.loading .spinner-grow {
  margin-bottom: -.1em;
}
</style>
