require 'gist'
require 'tempfile'
require 'digest/sha1'
require 'json'

module Nwcopy
  class Gist
    class << self
      attr_writer :gist
    end

    def self.unavailable_message
      "Github is not configured. Cannot use Gist."
    end

    def self.available?
      !gist.send(:auth).empty?
    end

    def self.time
      Time.parse(latest_gist["created_at"])
    end

    def self.copy clipboard
      digest = Digest::SHA1.hexdigest clipboard
      gist.write [{:filename => digest, :input => clipboard}], false
    end

    def self.paste
      gist.read latest_gist["repo"]
    end

    private
    def self.latest_gist
      gist.list["gists"].sort{|x, y| Time.parse(y["created_at"]) <=> Time.parse(x["created_at"])}.first
    end

    def self.gist
      @gist || ::Gist
    end
  end
end

module ::Gist
  def self.list
    JSON.parse open("http://gist.github.com/api/v1/json/gists/#{config('github.user')}").read
  end
end
