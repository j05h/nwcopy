require 'net/http/post/multipart'
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
      # This looks weird. Deal is, STDIN returns - as a filename, so returning - here removes extra testing.
      filename = data.respond_to?(:filename) ? data.filename : '-'

      io = if filename.match(/-/)
        CompositeReadIO.new data
      else
        UploadIO.new(ARGF, data, data.filename)
      end

      url = URI.parse("#{base_url}/copy")
      req = Net::HTTP::Post::Multipart.new url.path, 'data' => io
      res = start req, url

      res.body
    end


    def self.paste
      url = URI.parse("#{base_url}/paste")

      req = Net::HTTP::Get.new(url.path)
      res = start req, url

      file = res['Location'].split('/').last

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
      ENV['NWCOPY_TEST'] == 'true' ? 'http://localhost:3000' : 'http://nwcopy.heroku.com'
    end

    def self.credentials
      ENV['NWCOPY_CREDS'].split(':')
    end

  end
end
