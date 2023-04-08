# Python Gateway

There is no need for Python other than providing minimalistic endpoints for accessing specific modules, such as estimating OpenAI tokens using [tiktoken](https://github.com/openai/tiktoken).

```bash
pip install -r requirements.txt
python server.py --port 3094
```

`/tokens`
```json
{
  "model": "text-embedding-ada-002",
  "text": "hello"
}
```
