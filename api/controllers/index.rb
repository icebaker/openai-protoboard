# frozen_string_literal: true

module IndexController
  def self.index
    {
      service: 'protoboard',
      version: '0.0.1'
    }
  end
end
