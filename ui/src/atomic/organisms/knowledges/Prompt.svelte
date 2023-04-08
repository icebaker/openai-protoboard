<script>
  import Protoboard from '../../../components/protoboard.js';
  import TextAreaAtom from '../../atoms/TextArea.svelte';

  export let scope;
  export let updateResults;

  let state = 'ready';

  const sendForm = async (query) => {
    state = 'loading';

    updateResults({ state: 'loading', results: [], query: query });

    const results = (
      await Protoboard.post('/glimpses/search', {
        scope: scope,
        model: 'text-embedding-ada-002',
        input: query,
        distance: 0.3,
        limit: 3
      })
    )['success'];

    updateResults({ state: 'ready', results: results, query: query });

    state = 'ready';
  };
</script>

<TextAreaAtom
  label="Enter a thought to explore glimpses..."
  placeholder="put a thought here"
  disabled={state !== 'ready'}
  handler={sendForm}
/>
