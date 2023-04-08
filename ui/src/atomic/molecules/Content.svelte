<!-- MarkdownRenderer.svelte -->
<script>
  import { onMount, afterUpdate } from 'svelte';
  import * as marked from 'marked';
  import Prism from 'prismjs';
  import 'prismjs/components/prism-json.min';
  import 'prismjs/components/prism-ruby.min';
  import 'prismjs/components/prism-lisp.min';
  import 'prismjs/themes/prism-okaidia.css';
  import 'prism-svelte';

  export let content;

  let html = '';

  function highlightCode() {
    const codeBlocks = document.querySelectorAll('pre code');
    codeBlocks.forEach((block) => {
      Prism.highlightElement(block);
    });
  }

  $: if (content) {
    html = marked.parse(content);
    afterUpdate(highlightCode);
  }

  onMount(highlightCode);
</script>

<div class="markdown">
  {@html html}
</div>

<style>
  :global(.markdown img) {
    width: 100%;
  }
</style>
