# frozen_string_literal: true

require 'digest'

require_relative '../components/llm'
require_relative '../components/badger'
require_relative '../helpers/roda'

module EmbeddingsController
  def self.create(params)
    params[:input] = params[:input].to_s

    hash = Digest::SHA256.hexdigest(params[:input])

    params[:model] = params[:model] || 'text-embedding-ada-002'

    badger_key = ['embedding', params[:model], hash].compact.join(':')

    return Badger.instance.get(badger_key) if Badger.instance.exists?(badger_key)

    embedding = {
      at: Time.now, hash:,
      input: { model: params[:model], input: params[:input] },
      output: nil
    }

    response = LLM.instance.client.embeddings(parameters: embedding[:input])

    embedding[:output] = Helpers::Roda.symbolize_keys(JSON.parse(response.to_s))

    Badger.instance.set(badger_key, embedding)

    embedding
  end
end
