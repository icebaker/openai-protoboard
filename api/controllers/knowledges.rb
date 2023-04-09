# frozen_string_literal: true

require 'liquid'
require 'securerandom'
require 'uuid'

require_relative '../components/badger'
require_relative '../components/llm'
require_relative '../components/tokens'
require_relative '../components/weaviate'
require_relative '../helpers/roda'
require_relative './chats'
require_relative './embeddings'
require_relative './files'
require_relative './knowledges/glimpses'

module KnowledgesController
  def self.index(params)
    Badger.instance.get("knowledges:#{params[:scope]}") || []
  end

  def self.download(params)
    badger_key = [
      'knowledge', params[:scope], params[:model], params[:hash]
    ].compact.join(':')

    knowledge = Badger.instance.get(badger_key)

    knowledge

    { path: knowledge[:path], filename: knowledge[:source] }
  end

  def self.upload(content_type, body)
    params = Helpers::Roda.parse_multipart_form_data(body, content_type)

    content = FilesController.read(params[:file])

    knowledge_hash = Digest::SHA256.hexdigest(content)

    badger_key = [
      'knowledge', params[:scope], params[:model], knowledge_hash
    ].compact.join(':')

    return Badger.instance.get(badger_key) if Badger.instance.exists?(badger_key)

    tokens = Tokens.instance.count(content:)

    parts = (tokens / params[:tokens_per_glimpse].to_f).ceil

    fragments = split_into_n_parts(content, parts)

    if params[:intersections] != 'false' && params[:intersections]
      fragments.concat(
        split_into_n_parts(content, parts, intersections: true)
      )
    end

    embeddings = []

    fragments.each do |fragment|
      embeddings << EmbeddingsController.create(
        {
          model: params[:model],
          input: fragment
        }
      )
    end

    glimpses = []

    path = FilesController.store(params[:file], badger_key)

    embeddings.each do |embedding|
      glimpses << GlimpsesController.create(
        {
          knowledge_hash:,
          source: params[:file][:filename],
          scope: params[:scope],
          model: embedding[:input][:model],
          path:,
          content: embedding[:input][:input],
          vector: embedding[:output][:data][0][:embedding]
        }
      )
    rescue StandardError => e
      require 'pry'
      binding.pry
    end

    knowledge = {
      created_at: Time.now,
      key: badger_key,
      hash: knowledge_hash,
      source: params[:file][:filename],
      scope: params[:scope],
      model: params[:model],
      tokens: params[:intersections] == 'true' ? tokens * 2 : tokens,
      glimpses: glimpses.map { |glimpse| glimpse[:key] },
      path:
    }

    Badger.instance.set(badger_key, knowledge)

    badger_knowledges_key = "knowledges:#{params[:scope]}"

    knowledges = Badger.instance.get(badger_knowledges_key) || []

    knowledges.prepend(
      knowledge.except(:content)
    )

    Badger.instance.set(badger_knowledges_key, knowledges)

    FilesController.close_and_unlink(params[:file])

    knowledge
  end

  def self.split_into_n_parts(str, n, intersections: false)
    length = str.length
    part_length = (length / n.to_f).ceil

    str = str.slice((part_length / 2.0).round..-1) if intersections

    str.chars.each_slice(part_length).map(&:join)
  end
end
