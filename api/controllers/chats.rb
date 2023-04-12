# frozen_string_literal: true

require 'securerandom'

require_relative '../components/llm'
require_relative '../components/badger'
require_relative '../helpers/roda'
require_relative './knowledges/glimpses'

module ChatsController
  def self.index(params)
    Badger.instance.get("chats:#{params[:scope]}") || []
  end

  def self.delete(id, params)
    chats = Badger.instance.get("chats:#{params[:scope]}") || []

    Badger.instance.delete("chat:#{id}")

    chats = chats.filter do |chat|
      chat[:id] != id
    end

    Badger.instance.set("chats:#{params[:scope]}", chats)

    true
  end

  def self.create(params)
    chats_key = "chats:#{params[:scope]}"

    chats = Badger.instance.get(chats_key) || []

    chat = {
      id: SecureRandom.hex,
      kind: params[:kind],
      description: params[:description],
      scope: params[:scope],
      system_message: params[:system_message],
      created_at: Time.now,
      history: []
    }

    chats.prepend(chat)

    Badger.instance.set(chats_key, chats)

    Badger.instance.set("chat:#{chat[:id]}", chat)

    chat[:history] = chat[:history].reverse if chat[:history]

    chat
  end

  def self.history(id, params)
    chat = Badger.instance.get("chat:#{id}")

    chat[:history] = chat[:history].reverse if chat[:history]

    if params[:verbose]
      chat
    else
      chat[:history] ? chat[:history].map { |event| event[:input][:message] } : []
    end
  end

  def self.complete(id, chat, params)
    model = params[:model] || 'text-davinci-003'
    temperature = params[:temperature] || 0.7
    content = params[:content] || ''

    glimpses = if (params[:glimpses]).zero?
                 []
               else
                 GlimpsesController.search(
                   {
                     scope: chat[:scope],
                     model: 'text-embedding-ada-002',
                     input: params[:message],
                     distance: params[:distance] || 0.80,
                     limit: params[:glimpses] || 1
                   }
                 )
               end

    if params[:content] != ''
      chat[:history] << {
        at: Time.now,
        edit: { content: params[:content] },
        input: {
          model:, temperature:, message: {
            role: 'user', content: (params[:content]).to_s
          }
        }
      }
    end

    glimpses&.reverse&.each do |glimpse|
      content += "#{glimpse[:content]}\n"

      chat[:history] << {
        at: Time.now,
        glimpse:,
        input: {
          model:, temperature:, message: {
            role: 'user', content: (glimpse[:content]).to_s
          }
        }
      }
    end

    chat[:history] << {
      at: Time.now,
      input: {
        model:,
        temperature:,
        message: { role: 'user', content: params[:message] }
      }
    }

    if content == ''
      input = {
        model:,
        prompt: params[:message],
        temperature:,
        suffix: params[:suffix] && params[:suffix] != '' ? params[:suffix] : nil
      }

      return { input:, chat: } if params[:preview] && params[:verbose]

      response = LLM.instance.client.completions(parameters: input)
    else
      input = {
        model:,
        input: content,
        instruction: params[:message],
        temperature:
      }

      return { input:, chat: } if params[:preview] && params[:verbose]

      response = LLM.instance.client.edits(parameters: input)
    end

    output = JSON.parse(response.to_s)

    chat[:history].last[:output] = output

    return output unless output['created']

    chat[:history].push(
      {
        at: Time.at(output['created']),
        input: { model:, temperature:,
                 message: { content: output['choices'][0]['text'] } }
      }
    )

    Badger.instance.set("chat:#{id}", chat)

    chat[:history] = chat[:history].reverse if chat[:history]

    if params[:verbose]
      { input:, output:, chat: }
    else
      chat[:history].map { |event| event[:input][:message] }
    end
  end

  def self.update(id, params)
    chat = Badger.instance.get("chat:#{id}")

    return complete(id, chat, params) if chat[:kind] == 'completion'

    model = params[:model] || 'gpt-3.5-turbo'
    temperature = params[:temperature] || 0.7

    if chat[:history].empty?
      chat[:history] << {
        at: Time.now,
        input: {
          model:,
          temperature:,
          max_tokens: params[:max_tokens] || 1024,
          user: params[:user] || id,
          message: {
            role: 'system',
            content: chat[:system_message] && chat[:system_message] != '' ? chat[:system_message] : 'You are a helpful assistant.'
          }
        }
      }
    end

    # TODO: Should you give preivous messages for the search?
    #       Or would it just bring repeated glimpses?
    # Option 2: If the glimpse (or knolodge?) is already in the conversation,
    # remove the old one and add this new one!
    glimpses = if (params[:glimpses]).zero?
                 []
               else
                 GlimpsesController.search(
                   {
                     scope: chat[:scope],
                     model: 'text-embedding-ada-002',
                     input: params[:message],
                     distance: params[:distance] || 0.80,
                     limit: params[:glimpses] || 1
                   }
                 )
               end

    glimpses&.reverse&.each do |glimpse|
      chat[:history] << {
        at: Time.now,
        glimpse:,
        input: {
          model:, temperature:, message: {
            role: 'user', content: (glimpse[:content]).to_s
          }
        }
      }
    end

    chat[:history] << {
      at: Time.now,
      input: { model:, temperature:, message: { role: 'user', content: params[:message] } }
    }

    input = {
      model:,
      messages: chat[:history].map { |event| event[:input][:message] }, # Required.
      temperature:
    }

    if params[:preview] && params[:verbose]
      return { input:, chat: }
    elsif params[:preview]
      return chat[:history].map { |event| event[:input][:message] }
    end

    done = false

    until done
      input = {
        model:,
        messages: chat[:history].map { |event| event[:input][:message] }, # Required.
        temperature:
      }

      response = LLM.instance.client.chat(parameters: input)

      output = JSON.parse(response.to_s)

      if chat[:history].size > 2 && output['error'] && output['error']['code'] == 'context_length_exceeded'
        index_to_remove = nil

        # TODO: This way, a new glimpse will never join,
        # because only the glimpse will exists, so, we need
        # to balance removing glimpses with other things,
        # maybe the best way is just to remove the older thing...
        # chat[:history].each_with_index do |event, i|
        #   if event[:glimpse]
        #     index_to_remove = i
        #     break
        #   end
        # end

        # if index_to_remove.nil?
        #   chat[:history].each_with_index do |event, i|
        #     unless %w[user system].include?(event[:input][:message][:role])
        #       index_to_remove = i
        #       break
        #     end
        #   end
        # end

        if index_to_remove.nil?
          chat[:history].each_with_index do |event, i|
            if event[:input][:message][:role] != 'system'
              index_to_remove = i
              break
            end
          end
        end

        if index_to_remove.nil?
          done = true
        else
          chat[:history].delete_at(index_to_remove)
        end
      else
        done = true
      end
    end

    chat[:history].last[:output] = output

    return output unless output['created']

    chat[:history].push(
      {
        at: Time.at(output['created']),
        input: { model:, temperature:,
                 message: Helpers::Roda.symbolize_keys(output['choices'][0]['message']) }
      }
    )

    Badger.instance.set("chat:#{id}", chat)

    chat[:history] = chat[:history].reverse if chat[:history]

    if params[:verbose]
      { input:, output:, chat: }
    else
      chat[:history].map { |event| event[:input][:message] }
    end
  end
end
