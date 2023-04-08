<script>
  import { onMount } from 'svelte';

  export let title;

  export let size = 'md';

  export let onComplete = undefined;

  let modalElement = undefined;
  let modal = undefined;

  onMount(() => {
    if (modalElement) {
      modal = new bootstrap.Modal(modalElement, {});

      modalElement.addEventListener('hidden.bs.modal', () => {
        if (onComplete) onComplete();
      });
    }
  });

  const backdrop = undefined;
  let data = undefined;

  export const open = (modalData) => {
    data = modalData;
    if (modal) {
      modal.show();
    }
  };
</script>

<div
  bind:this={modalElement}
  data-bs-backdrop={backdrop}
  class={`modal modal-${size} fade`}
  tabindex="-1"
>
  <div class="modal-dialog modal-dialog modal-dialog-centered">
    <div class="modal-content">
      <div class="modal-header">
        <h5 class="modal-title">{title}</h5>
        <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close" />
      </div>
      <div class="modal-body">
        <slot {data} />
      </div>
    </div>
  </div>
</div>
