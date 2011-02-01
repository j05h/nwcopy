$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'nwcopy/dropbox'

module Nwcopy
  def self.copy
    data = read_data
    if Nwcopy::Dropbox.available?
      Nwcopy::Dropbox.copy data
    else
      STDERR << NwCopy::Dropbox.unavailable_message
    end
  end

  def self.paste
    if Nwcopy::Dropbox.available?
      if clipboard = Nwcopy::Dropbox.paste
        `echo "#{clipboard}" | pbcopy` unless `which pbcopy`.empty?
        clipboard
      end
    else
      STDERR << NwCopy::Dropbox.unavailable_message
    end
  end

  private
  def self.read_data
    if ARGF.file == STDIN
      STDIN.read_nonblock(1) + STDIN.read
    else
      ARGF.read
    end
  rescue IO::WaitReadable => e
    unless `which pbpaste`.empty?
      `pbpaste`
    else
      STDERR << 'Nothing to do!'
    end
  end

end
