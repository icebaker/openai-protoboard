<script>
  import Protoboard from '../../../components/protoboard.js';

  export let scope;
  export let updateResults;

  let state = 'ready';
  let value = '';
  let textAreaElement = undefined;

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

  const handleEnterKey = async (event) => {
    if (event.key === 'Enter' && !event.shiftKey) {
      event.preventDefault();

      const query = `${value}`;

      value = value.replace(/(\r\n|\n|\r)/gm, '');
      textAreaElement.value = value;
      value = '';

      await sendForm(query);
    }
  };
</script>

<div class="form-floating">
  <textarea
    bind:this={textAreaElement}
    on:keydown={handleEnterKey}
    bind:value
    disabled={state !== 'ready'}
    class="form-control"
    placeholder="put a thought here"
    id="floatingTextarea"
  />
  <label for="floatingTextarea">Enter a thought to explore glimpses...</label>
</div>
