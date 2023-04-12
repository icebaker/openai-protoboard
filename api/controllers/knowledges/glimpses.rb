# frozen_string_literal: true

require 'liquid'
require 'securerandom'
require 'uuid'

require_relative '../../components/badger'
require_relative '../../components/llm'
require_relative '../../components/tokens'
require_relative '../../components/weaviate'
require_relative '../../helpers/roda'
require_relative '../chats'
require_relative '../embeddings'

module GlimpsesController
  def self.create(params)
    glimpse_hash = Digest::SHA256.hexdigest(params[:content])

    badger_key = [
      'glimpse', params[:scope], params[:model], params[:knowledge_hash], glimpse_hash
    ].compact.join(':')

    return Badger.instance.get(badger_key) if Badger.instance.exists?(badger_key)

    id = UUID.generate

    properties = {
      key: badger_key,
      path: params[:path],
      scope: params[:scope],
      knowledge_hash: params[:knowledge_hash],
      hash: glimpse_hash,
      source: params[:source],
      content: params[:content],
      model: params[:model]
    }

    response = Weaviate.instance.create(
      id, properties, params[:vector]
    )

    glimpse = {
      id:,
      key: badger_key,
      properties:,
      vector: params[:vector],
      weaviate: Helpers::Roda.symbolize_keys(response)
    }

    Badger.instance.set(badger_key, glimpse)

    glimpse
  end

  def self.search(params)
    embedding_params = params.slice(:model, :input)

    embedding_params[:input] = params[:query] if !embedding_params[:input] && params[:query]

    embedding = EmbeddingsController.create(embedding_params)

    vector = embedding[:output][:data][0][:embedding]

    result = Weaviate.instance.search(params, vector)

    return [] if result['error']

    Helpers::Roda.symbolize_keys(
      Weaviate.instance.search(params, vector)['data']['Get']['Glimpse']
    )
  end

  def self.split_string_into_n_parts(str, n)
    length = str.length
    part_length = (length / n.to_f).ceil
    str.chars.each_slice(part_length).map(&:join)
  end
end
