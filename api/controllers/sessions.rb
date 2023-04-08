# frozen_string_literal: true

require 'securerandom'

require_relative '../components/llm'
require_relative '../components/badger'
require_relative '../helpers/roda'
require_relative './knowledges'

module SessionsController
  def self.index(_params)
    Badger.instance.get('sessions') || []
  end

  def self.show(id)
    Badger.instance.get("session:#{id}")
  end

  def self.delete(id)
    sessions = Badger.instance.get('sessions') || []

    Badger.instance.delete("session:#{id}")

    sessions = sessions.filter do |session|
      session[:id] != id
    end

    Badger.instance.set('sessions', sessions)

    true
  end

  def self.create(params)
    sessions = Badger.instance.get('sessions') || []

    session = {
      id: SecureRandom.hex,
      created_at: Time.now,
      name: params[:name]
    }

    sessions.prepend(session)

    Badger.instance.set("session:#{session[:id]}", session)

    Badger.instance.set('sessions', sessions)

    session
  end
end
