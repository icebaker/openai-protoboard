# frozen_string_literal: true

require 'singleton'
require 'faraday'
require 'json'

class Weaviate
  include Singleton

  def initialize
    @base_uri = "http://#{ENV.fetch('WEAVIATE_ADDRESS')}"
    @api_key = nil
    @conn = Faraday.new(url: @base_uri) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
  end

  def create(key, properties, vector)
    body = {
      id: key,
      class: 'Glimpse',
      properties:,
      vector:
    }.to_json

    response = @conn.post do |req|
      req.url '/v1/objects'
      req.headers['Content-Type'] = 'application/json'
      req.headers['apikey'] = @api_key
      req.body = body
    end

    JSON.parse(response.body)
  end

  def cosine_similarity
    @cosine_similarity ||= File.read('queries/cosine_similarity.gql')
  end

  def search(params, vector)
    template = Liquid::Template.parse(cosine_similarity)

    query = template.render(
      'vector' => "[#{vector.join(', ')}]",
      'scope' => params[:scope] || 'global',
      'limit' => params[:limit] || 10,
      'distance' => params[:distance] || 1
    )

    body = { query: }.to_json

    response = @conn.post do |req|
      req.url '/v1/graphql'
      req.headers['Content-Type'] = 'application/json'
      req.headers['apikey'] = @api_key
      req.body = body
    end

    JSON.parse(response.body)
  end
end
