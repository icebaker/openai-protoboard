# frozen_string_literal: true

require_relative '../components/llm'

module ModelsController
  def self.index
    # return LLM.instance.client.models.list.parsed_response['data']
    LLM.instance.client.models.list.parsed_response['data'].map do |model|
      {
        id: model['id'],
        owner: model['owned_by'],
        created_at: Time.at(model['created'])
      }
    end.sort_by { |model| -model[:created_at].to_i }.slice(0, 5)
  end
end
