# frozen_string_literal: true

require 'singleton'

require 'zache'

class Cache
  include Singleton

  attr_reader :zache

  def initialize
    @zache = Zache.new
  end
end
