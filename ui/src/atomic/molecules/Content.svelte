<script>
  import { onMount, afterUpdate } from 'svelte';
  import * as marked from 'marked';
  import Prism from 'prismjs';
  import 'prismjs/components/prism-json.min';
  import 'prismjs/components/prism-ruby.min';
  import 'prismjs/components/prism-clojure.min';
  import 'prismjs/themes/prism-okaidia.css';
  import 'prism-svelte';

  export let content;
  export let direction;

  let html = '';

  function highlightCode() {
    const codeBlocks = document.querySelectorAll('pre code');
    codeBlocks.forEach((block) => {
      Prism.highlightElement(block);
    });
  }

  $: if (content) {
    html = marked.parse(content);
    const htmlPreview = new DOMParser().parseFromString(html, 'text/html');
    const bodyPreview = htmlPreview.querySelector('body');
    const elementCount = bodyPreview.getElementsByTagName('*').length;
    const firstElement = bodyPreview.querySelector('*');

    if (elementCount === 1 && firstElement.tagName === 'P') {
      html = `<p>${content.replace(/(\r\n|\n|\r)/gm, '<br>')}</p>`;
    } else {
      afterUpdate(highlightCode);
    }
  }

  onMount(highlightCode);
</script>

<div class={`markdown text-break direction-${direction}`}>
  {@html html}
</div>

<style>
  :global(.markdown img) {
    width: 100%;
  }

  :global(.markdown.direction-end ul, .markdown.direction-end ol) {
    display: inline-block;
  }

  :global(.markdown.direction-end li) {
    /*    direction: rtl;*/
    /*    list-style-position: inside;*/
    text-align: left;
  }
</style>
