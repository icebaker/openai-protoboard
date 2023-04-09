# frozen_string_literal: true

require_relative '../components/llm'
require_relative '../components/cache'

module ModelsController
  # https://platform.openai.com/docs/models
  PURPOSE = [
    { regex: /code|cushman/, purpose: 'code' },
    { regex: /moderation/, purpose: 'moderation' },
    { regex: /embedding/, purpose: 'embedding' },
    { regex: /edit/, purpose: 'edit' },
    { regex: /whisper/, purpose: 'audio' },
    { regex: /gpt/, purpose: 'chat' },
    { regex: /babbage|davinci|curie|ada/, purpose: 'completion' }
  ].freeze

  def self.index(params)
    # 1 Hour Cache
    models = Cache.instance.zache.get(:models, lifetime: 1 * 60) do
      LLM.instance.client.models.list.parsed_response['data']
    end.map do |model|
      purpose = PURPOSE.find do |pattern|
        if (model['id'] =~ pattern[:regex]).nil?
          false
        else
          pattern[:purpose]
        end
      end

      {
        id: model['id'],
        title: "#{purpose ? "#{purpose[:purpose]}: " : ''}#{model['id']}",
        owner: model['owned_by'],
        created_at: Time.at(model['created']),
        purpose: purpose ? purpose[:purpose] : nil
      }
    end.sort_by { |model| -model[:created_at].to_i }.sort_by { |model| model[:purpose] }

    return models unless params[:purpose]

    models.filter { |model| model[:purpose] == params[:purpose] }
  end
end
