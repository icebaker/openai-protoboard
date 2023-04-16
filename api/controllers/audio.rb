# frozen_string_literal: true

require 'securerandom'

require_relative '../components/llm'

module AudioController
  PATH = 'data/audio'

  def self.to_text(content_type, body)
    params = Helpers::Roda.parse_multipart_form_data(body, content_type)

    extension = params[:format] || 'webm'

    path = "data/audio/#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}-#{SecureRandom.hex}.#{extension}"

    FileUtils.mkdir_p(PATH)
    File.write(path, params[:audio][:tempfile].read)

    # .translate if you want it always translated to english.
    response = LLM.instance.client.transcribe(
      parameters: { model: 'whisper-1', file: File.open(path, 'rb') }
    )

    FileUtils.rm_f(path)

    response.parsed_response
  end
end
