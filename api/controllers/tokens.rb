# frozen_string_literal: true

require 'securerandom'

require_relative '../components/llm'
require_relative '../components/badger'
require_relative '../components/tokens'
require_relative '../helpers/roda'
require_relative './knowledges'
require_relative './chats'
require_relative './files'

module TokensController
  COST_PER_1K_TOKENS = 0.0004

  def self.overview(params)
    tokens = 0
    dollars = 0.0
    params.each do |file|
      tokens += file[:tokens]
      dollars += (((file[:tokens].to_f / 1000.0).ceil.to_f * COST_PER_1K_TOKENS) * 100).ceil / 100.0
    end

    { tokens:, dollars: (dollars * 100).ceil / 100.0 }
  end

  def self.estimate(content_type, body)
    params = Helpers::Roda.parse_multipart_form_data(body, content_type)

    content = FilesController.read(params[:file])

    # (n * 2) because of intersections: true
    tokens = Tokens.instance.count(content:, model: 'text-embedding-ada-002') * 2

    dollars = (((tokens.to_f / 1000.0).ceil.to_f * COST_PER_1K_TOKENS) * 100).ceil / 100.0

    {
      source: params[:file][:filename],
      hash: Digest::SHA256.hexdigest(content),
      model: 'text-embedding-ada-002',
      tokens:,
      dollars:
    }
  end
end
