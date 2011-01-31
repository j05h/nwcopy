require 'digest/sha1'

module Nwcopy

  def self.dropbox_dir
    File.expand_path '~/Dropbox'
  end

  def self.nwcopy_dir
    File.join dropbox_dir, 'nwcopy'
  end

  def self.init
    unless File.exists? dropbox_dir
      $stderr << "You must have Dropbox installed to use this version of nwcopy. (http://getdropbox.com/)\n"
      exit
    end

    unless File.exists? nwcopy_dir
      puts "Creating nwcopy directory at #{nwcopy_dir}"
      Dir.mkdir nwcopy_dir
    end
  end

  def self.copy clipboard = `pbpaste`
    digest = Digest::SHA1.hexdigest clipboard
    nwcopy_file = File.join nwcopy_dir, digest
    File.open(nwcopy_file, 'w+') do |f|
      f << clipboard
    end
    nwcopy_file
  end

  def self.paste
    files = Dir.glob(File.join(nwcopy_dir,'*')).sort do |file1, file2|
      File.new(file2).mtime <=> File.new(file1).mtime
    end

    clipboard = File.new(files.first).read
    `echo #{clipboard} | pbcopy`
    clipboard
  end
end
