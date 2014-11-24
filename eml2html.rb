#! /usr/bin/env ruby

require 'mail'
require 'zip'

class MessageConverter

  class Attachment
    attr_reader :cid, :name, :content
    def initialize(cid, name, content)
      @cid, @name, @content = cid, name, content
    end
  end

  def initialize(message)
    @message = Mail.read(message)
    @basename = File.basename(message, '.eml')
    read_attachments
  end

  def save_files!
    [:txt, :html, :zip].each do |ext|
      send(:"save_#{ext}")
    end
  end

  def save_txt
    File.write filename(:txt), text_body
  end

  def save_html
    File.write filename(:html), html_body
  end

  def save_zip(include_html = false)
    Zip::File.open(filename(:zip) ,Zip::File::CREATE) do |zipfile|
      if include_html
        zipfile.get_output_stream(filename(:html)) do |out|
          out << html_body
        end
      end

      each_attachment do |name, content|
        zipfile.get_output_stream(name) do |out|
          out << content
        end
      end
    end
  end

  private

  def filename(ext = nil)
    [@basename, ext].compact.join('.')
  end

  def text_body
    @message.text_part.body.to_s
  end

  def html_body
    replace_images_src(@message.html_part.body.to_s)
  end

  def each_attachment
    @attachments.each do |a|
      yield a.name, a.content
    end
  end

  def read_attachments
    @attachments = @message.parts.map do |part|
      next if part.multipart?
      name = part['Content-Type'].to_s.split('; ').last[/^filename="(.*)"$/, 1]
      Attachment.new(part.cid, name, part.body.to_s)
    end.compact
  end

  def replace_images_src(html)
    html.gsub(/(?<=src=['"])(cid:)([^'"]+)(?=['"])/) do |match|
      cid = match.sub(/^cid:/, '')
      @attachments.find{|a| a.cid == cid}.name
    end
  end
end

def main(email_file)
  raise ArgumentError, "No email file" if email_file.nil? || email_file.empty?
  converter = MessageConverter.new(email_file)
  converter.save_files!
end

main(ARGV[0])
