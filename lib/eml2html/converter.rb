require 'mail'
require 'zip'

module Eml2Html
  class Attachment
    attr_reader :cid, :name, :content, :cids_in_body
    def initialize(cid, name, content)
      @cid, @name, @content = cid, name, content
      @cids_in_body = []
    end
  end

  class Converter
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
      File.write(filename(:txt), text_body)
    end

    def save_html
      File.write(filename(:html), html_body)
      each_attachment do |name, content|
        File.write(name, content)
      end
    end

    def save_zip(options = {})
      Zip::File.open(filename(:zip), Zip::File::CREATE) do |zipfile|
        if options[:include_html]
          zipfile.get_output_stream(filename(:html)) do |out|
            out << html_body
          end
        end

        if options[:include_text]
          zipfile.get_output_stream(filename(:txt)) do |out|
            out << text_body
          end
        end

        each_attachment do |name, content|
          zipfile.get_output_stream(name) do |out|
            out << content
          end
        end
      end
    end

    def get_attachments(include_in_doc=false)
      attachments = []
      if include_in_doc
        attachments = @attachments
      else
        @attachments.each do |a|
          unless @cids_in_body.includes(a.cid)
            attachments.push(a)
          end
        end
      end
      attachments
    end

    def get_html
      html_body
    end

    def get_attachment(file_name)
      each_attachment do |name, content|
        if name == file_name
          return content
        end
      end
      nil
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
      @attachments = @message.parts.flat_map do |part|
        if part.multipart?
          part.parts.map do |part|
            name = part['Content-Type'].filename
            next unless name
            Attachment.new(part.cid, name, part.body.to_s)
          end
        else
          name = part['Content-Type'].filename
          next unless name
          Attachment.new(part.cid, name, part.body.to_s)
        end
      end.compact
    end

    def replace_images_src(html)
      html.gsub(/(?<=src=['"])cid:[^'"]+(?=['"])/) do |match|
        cid = match.sub(/^cid:/, '')
        cids_in_body.push(cid)
        @attachments.find{|a| a.cid == cid}.name
      end
    end
  end
end
