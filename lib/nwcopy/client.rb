require 'net/http/post/multipart'
require 'tempfile'
require 'json'

module Nwcopy
  class Client
    class << self
      attr_writer :gist
    end

    def self.unavailable_message
      "nwcopy is not configured. Go to nwcopy.heroku.com. Then set $NWCOPY_CREDS."
    end

    def self.available?
      ENV['NWCOPY_CREDS']
    end

    def self.time
      Time.now
    end

    def self.copy data
      if data.respond_to? :filename
        filename = data.filename
      else
        filename = nil
        @tmpfile = Tempfile.new 'nwcopy'
        @tmpfile.write(data.read)
        @tmpfile.close
        data = File.open @tmpfile.path
      end

      io = UploadIO.new(data, nil, filename)

      url = URI.parse("#{base_url}/copy")
      req = Net::HTTP::Post::Multipart.new url.path, 'data' => io
      res = start req, url

      res.body
    ensure
      @tmpfile.unlink if @tmpfile
      @tmpfile = nil
    end


    def self.paste url_or_hash = nil
      url = if url_or_hash
        hash = url_or_hash.split('/').last
        URI.parse("#{base_url}/pastes/#{hash}")
      else
        URI.parse("#{base_url}/paste")
      end

      req = Net::HTTP::Get.new(url.path)
      res = start req, url

      file = res['Location'] ? res['Location'].split('/').last : nil

      if file && !File.exists?(file)
        File.open file, 'w+' do |f|
          f << res.body
        end
        "Pasted to #{file}"
      else
        res.body
      end
    end

    private
    def self.start req, url
      req.basic_auth *credentials
      Net::HTTP.start(url.host, url.port) do |http|
        http.request req
      end
    end

    def self.base_url
      ENV['NWCOPY_TEST'] == 'true' ? 'http://localhost:3000' : 'http://nwcopy.net'
    end

    def self.credentials
      ENV['NWCOPY_CREDS'].split(':')
    end

  end
end
