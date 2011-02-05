require 'digest/sha1'

module Nwcopy
  class Dropbox
    class << self
      attr_accessor :dropbox_base
    end

    def self.unavailable_message
      "Dropbox was not found at #{nwcopy_dir}. Get it at http://getdropbox.com/"
    end

    def self.available?
      return false unless File.exists? dropbox_dir

      unless File.exists? nwcopy_dir
        Dir.mkdir nwcopy_dir
      end

      File.exists? nwcopy_dir
    end

    def self.copy io
      clipboard = io.read
      digest = Digest::SHA1.hexdigest clipboard
      nwcopy_file = File.join nwcopy_dir, digest
      File.open(nwcopy_file, 'w+') do |f|
        f << clipboard
      end
      nwcopy_file
    end

    # Used to determine which plugin has the newest file.
    def self.time
      latest_file ? latest_file.mtime : nil
    end

    def self.paste ignored = nil
      latest_file.read
    end

    private # These methods are not part of the API

    def self.files
      Dir.glob(File.join(nwcopy_dir,'*')).map do |f|
        File.new(f)
      end
    end

    def self.latest_file
      files.sort do |file1, file2|
        file2.mtime <=> file1.mtime
      end.first
    end

    def self.dropbox_dir
      File.expand_path(dropbox_base || '~/Dropbox')
    end

    def self.nwcopy_dir
      File.join dropbox_dir, 'nwcopy'
    end

  end
end
