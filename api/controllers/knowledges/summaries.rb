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
require_relative '../knowledges'

module SummariesController
  MAXIMUM_GPT_35_TOKENS = (4096 * 0.9).to_i

  def self.create(params)
    # {
    #   knowledge: {
    #     hash: params[:knowledge][:hash],
    #     path: params[:knowledge][:path],
    #     source: params[:knowledge][:source],
    #     tokens: params[:knowledge][:tokens],
    #   },
    #   scope: params[:scope],
    #   model: params[:model],
    #   tokens: params[:tokens]
    # }

    badger_key = [
      'summary', params[:scope], params[:model], params[:knowledge][:hash], params[:tokens], :v0
    ].compact.join(':')

    if Badger.instance.exists?(badger_key)
      content = Badger.instance.get(badger_key)
    else
      content = FilesController.read({ tempfile: File.open(params[:knowledge][:path]) })

      tokens = Tokens.instance.count(content:)

      parts = (tokens / MAXIMUM_GPT_35_TOKENS.to_f).ceil

      while tokens > params[:tokens] && parts > 1
        fragments_a = KnowledgesController.split_into_n_parts(content, parts)

        fragments_b = KnowledgesController.split_into_n_parts(content, parts, intersections: true)

        fragments = []

        (0..[fragments_a.size, fragments_b.size].max + 1).each do |index|
          fragments << fragments_a[index] if fragments_a[index]
          fragments << fragments_b[index] if fragments_b[index]
        end

        partial_summary = ''

        fragments.each do |fragment|
          # TODO: Cache this thing.
          response = LLM.instance.client.chat(
            parameters: {
              model: params[:model] || 'gpt-3.5-turbo',
              messages: [
                { role: 'system',
                  content: 'your role is to accurately comprehend the provided text and generate summaries according to the requested number of words, focusing on capturing the most essential information while maintaining clarity and coherence' },
                { role: 'user',
                  content: "summarize the following text close #{(fragment.scan(/\b\w+\b/).size / 2.0).to_i} words:" },
                { role: 'user', content: fragment }
              ],
              temperature: 0.7
            }
          )

          partial_summary += "\n#{response['choices'][0]['message']['content']}"
        end

        content = partial_summary

        tokens = Tokens.instance.count(content:)

        parts = (tokens / MAXIMUM_GPT_35_TOKENS.to_f).ceil
      end

      # 1 token ~= 4 chars in English
      # 1 token ~= ¾ words
      # 100 tokens ~= 75 words

      response = LLM.instance.client.chat(parameters: {
                                            model: params[:model] || 'gpt-3.5-turbo',
                                            messages: [
                                              { role: 'system',
                                                content: 'your role is to assist in enhancing the readability and coherence of text excerpts while maintaining consistency' },
                                              { role: 'user',
                                                content: "Edit provided excerpts; maintain context, meaning; ensure fluidity; aim for #{(params[:tokens].to_f * (3.0 / 4.0)).to_i} words:" },
                                              { role: 'user', content: }
                                            ],
                                            temperature: 0.7
                                          })

      content = response['choices'][0]['message']['content']

      Badger.instance.set(badger_key, content)
    end

     response = LLM.instance.client.chat(parameters: {
                                          model: params[:model] || 'gpt-3.5-turbo',
                                          messages: [
                                            { role: 'system',
                                              content: 'you are a professional translator' },
                                            { role: 'user',
                                              content: "translate the following text to PT-BR:" },
                                            { role: 'user', content: }
                                          ],
                                          temperature: 0.7
                                        })

    content = response['choices'][0]['message']['content']

    content
  end
end
