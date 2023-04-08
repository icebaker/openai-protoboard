import argparse
from flask import Flask, request, jsonify
import tiktoken

app = Flask(__name__)

@app.route('/tokens', methods=['POST'])
def tokens():
    data = request.get_json()
    if not data or 'text' not in data:
        return jsonify({"error": "No text provided"}), 400

    text = data['text']

    encoding = tiktoken.encoding_for_model(data['model'])

    tokens = encoding.encode(text)
    num_tokens = len(tokens)

    return jsonify({"tokens": num_tokens})

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='Run Flask app on custom port')
    parser.add_argument('--port', type=int, default=5000, help='Port number to run the Flask app')

    args = parser.parse_args()
    app.run(host='0.0.0.0', port=args.port)
