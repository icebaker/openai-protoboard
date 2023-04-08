# frozen_string_literal: true

require 'fileutils'
require 'pdf-reader'
require 'mimemagic'

module FilesController
  PATH = 'data/knowledge'

  def self.read(file)
    file[:tempfile].rewind

    mime_type = MimeMagic.by_magic(file[:tempfile])

    if mime_type && mime_type.subtype == 'pdf'
      reader = PDF::Reader.new(file[:tempfile])

      content = ''

      reader.pages.each { |page| content += page.text }

      return content
    end

    file[:tempfile].rewind
    file[:tempfile].read
  end

  def self.store(file, key)
    path = key.split(':')

    path[path.size - 1] = split_into_n_parts(path.last, 8)

    path = path.flatten.join('/')

    path = "#{PATH}/" + path.sub(/^knowledge/, '').sub(%r{^/}, '')

    FileUtils.mkdir_p(path)

    path = "#{path}/#{file[:filename]}"

    file[:tempfile].rewind
    File.write(path, file[:tempfile].read)

    path
  end

  def self.close_and_unlink(file)
    file[:tempfile].close
    file[:tempfile].unlink
  end

  def self.split_into_n_parts(str, n)
    length = str.length
    part_length = (length / n.to_f).ceil

    str.chars.each_slice(part_length).map(&:join)
  end
end
