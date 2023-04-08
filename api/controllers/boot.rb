# frozen_string_literal: true

module BootController
  def self.boot!
    logger = Logger.new($stdout)
    logger.info("Starting server on port #{ENV.fetch('PORT')}")
  end
end
