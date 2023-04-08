# frozen_string_literal: true

require 'rack'

module Helpers
  module Roda
    def self.parse_multipart_form_data(raw_data, content_type_header)
      boundary = content_type_header[/boundary=(.*)$/, 1]
      content_type = "multipart/form-data; boundary=#{boundary}"

      env = {
        'CONTENT_TYPE' => content_type,
        'CONTENT_LENGTH' => raw_data.length.to_s,
        'rack.input' => StringIO.new(raw_data)
      }

      symbolize_keys(Rack::Multipart.parse_multipart(env))
    end

    def self.body_to_params(request)
      body = request.body.read
      body.nil? || body == '' ? {} : Helpers::Roda.symbolize_keys(JSON.parse(body))
    end

    def self.symbolize_keys(object)
      case object
      when Hash
        object.each_with_object({}) do |(key, value), result|
          result[key.to_sym] = symbolize_keys(value)
        end
      when Array
        object.map { |e| symbolize_keys(e) }
      else
        object
      end
    end

    def self.safe_json(data)
      JSON.generate(data)
    rescue JSON::GeneratorError => _e
      begin
        JSON.generate(secure_json(Marshal.load(Marshal.dump(data))))
      rescue StandardError => e
        {
          class: e.class
        }
      end
    end

    def self.secure_json(node)
      case node
      when Hash
        result = {}
        node.each_key { |key| result[key] = secure_json(node[key]) }
      when Array
        result = []
        node.each { |value| result << secure_json(value) }
      when String
        begin
          JSON.generate(node)
          result = node
        rescue JSON::GeneratorError => _e
          result = { '!binary': node.unpack1('H*') }
        end
      else
        result = node
      end

      result
    end
  end
end
