# frozen_string_literal: true

require 'faraday'
require 'singleton'

class Tokens
  include Singleton

  attr_reader :address

  def initialize
    @base_uri = "http://#{ENV.fetch('PYTHON_GATEWAY_ADDRESS')}"
    @conn = Faraday.new(url: @base_uri) do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.adapter  Faraday.default_adapter
    end
  end

  def count(content:, model: 'text-embedding-ada-002')
    body = {
      model:,
      text: content
    }.to_json

    response = @conn.post do |req|
      req.url '/tokens'
      req.headers['Content-Type'] = 'application/json'
      req.body = body
    end

    JSON.parse(response.body)['tokens']
  end
end
