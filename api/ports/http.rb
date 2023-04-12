# frozen_string_literal: true

require 'json'

require_relative '../controllers/index'
require_relative '../controllers/sessions'
require_relative '../controllers/tokens'
require_relative '../controllers/models'
require_relative '../controllers/chats'
require_relative '../controllers/embeddings'
require_relative '../controllers/knowledges'
require_relative '../controllers/knowledges/glimpses'
require_relative '../controllers/knowledges/summaries'
require_relative '../helpers/roda'

module HTTP
  def self.routes(route, request, response)
    route.root do
      Helpers::Roda.safe_json(IndexController.index)
    end

    # Models --------------------------------------------------------

    route.get 'models' do
      Helpers::Roda.safe_json(
        ModelsController.index(Helpers::Roda.symbolize_keys(request.params))
      )
    end

    # Chats ---------------------------------------------------------

    route.get 'chats', String do |id|
      Helpers::Roda.safe_json(
        ChatsController.history(id, Helpers::Roda.symbolize_keys(request.params))
      )
    end

    route.post 'chats', String do |id|
      Helpers::Roda.safe_json(
        ChatsController.update(id, Helpers::Roda.body_to_params(request))
      )
    end

    route.get 'chats' do
      Helpers::Roda.safe_json(
        ChatsController.index(Helpers::Roda.symbolize_keys(request.params))
      )
    end

    route.post 'chats' do
      Helpers::Roda.safe_json(
        ChatsController.create(Helpers::Roda.body_to_params(request))
      )
    end

    route.delete 'chats', String do |id|
      Helpers::Roda.safe_json(
        ChatsController.delete(id, Helpers::Roda.symbolize_keys(request.params))
      )
    end

    # Embeddings ----------------------------------------------------

    route.get 'embeddings/models' do
      Helpers::Roda.safe_json(EmbeddingsController.models)
    end

    route.post 'embeddings' do
      Helpers::Roda.safe_json(
        EmbeddingsController.create(Helpers::Roda.body_to_params(request))
      )
    end

    # Knowledge -----------------------------------------------------

    route.post 'knowledges/summaries' do
      Helpers::Roda.safe_json(
        SummariesController.create(Helpers::Roda.body_to_params(request))
      )
    end

    route.get 'knowledges/download' do
      data = KnowledgesController.download(Helpers::Roda.symbolize_keys(request.params))
      response['Content-Disposition'] = "attachment; filename=\"#{data[:filename]}\""
      File.read(data[:path])
    end

    route.get 'knowledges' do
      Helpers::Roda.safe_json(
        KnowledgesController.index(Helpers::Roda.symbolize_keys(request.params))
      )
    end

    route.post 'knowledges' do
      Helpers::Roda.safe_json(
        KnowledgesController.upload(request.env['CONTENT_TYPE'], request.body.read)
      )
    end

    route.post 'tokens/estimate' do
      Helpers::Roda.safe_json(
        TokensController.estimate(request.env['CONTENT_TYPE'], request.body.read)
      )
    end

    route.post 'tokens/estimate/overview' do
      Helpers::Roda.safe_json(
        TokensController.overview(Helpers::Roda.body_to_params(request))
      )
    end

    # Session -------------------------------------------------------

    route.post 'glimpses/search' do
      Helpers::Roda.safe_json(
        GlimpsesController.search(Helpers::Roda.body_to_params(request))
      )
    end

    # Session -------------------------------------------------------

    route.get 'sessions' do
      Helpers::Roda.safe_json(
        SessionsController.index(Helpers::Roda.symbolize_keys(request.params))
      )
    end

    route.get 'sessions', String do |id|
      Helpers::Roda.safe_json(
        SessionsController.show(id)
      )
    end

    route.post 'sessions' do
      Helpers::Roda.safe_json(
        SessionsController.create(Helpers::Roda.body_to_params(request))
      )
    end

    route.delete 'sessions', String do |id|
      Helpers::Roda.safe_json(SessionsController.delete(id))
    end
  end
end
