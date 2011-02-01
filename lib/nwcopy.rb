$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'nwcopy/dropbox'
require 'nwcopy/gist'

module Nwcopy

  def self.plugins
    [Nwcopy::Gist, Nwcopy::Dropbox]
  end

  def self.copy
    data = read_data
    unavailable = []
    plugins.each do |plugin|
      if plugin.available?
        return plugin.copy data
      else
        unavailable << plugin.unavailable_message
      end
    end
    STDERR << unavailable.join("\n")
  end

  def self.paste
    unavailable = []
    plugins.each do |plugin|
      if plugin.available?
        if clipboard = plugin.paste
          `echo "#{clipboard}" | pbcopy` unless `which pbcopy`.empty?
          return clipboard
        end
      else
        unavailable << plugin.unavailable_message
      end
    end
    STDERR << unavailable.join("\n")
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
