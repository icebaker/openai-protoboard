# frozen_string_literal: true

require 'singleton'

require 'openai'

class LLM
  include Singleton

  attr_reader :client

  def initialize
    @client = OpenAI::Client.new(
      uri_base: ENV.fetch('OPENAI_API_ADDRESS'),
      access_token: ENV.fetch('OPENAI_API_KEY')
    )
  end
end
