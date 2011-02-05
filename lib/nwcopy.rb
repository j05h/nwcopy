$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) ||
  $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'nwcopy/client'
require 'nwcopy/dropbox'
require 'nwcopy/gist'

module Nwcopy

  def self.plugins
    [Nwcopy::Client, Nwcopy::Dropbox, Nwcopy::Gist]
  end

  def self.copy
    data = read_data
    unavailable = []
    plugins.each do |plugin|
      if plugin.available?
        return plugin.copy data
      else
        STDERR << plugin.unavailable_message
      end
    end
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
        STDERR << plugin.unavailable_message
      end
    end
  end

  private
  def self.read_data
    if ARGF.file == STDIN
      StringIO.new(STDIN.read_nonblock(1) + STDIN.read)
    else
      ARGF
    end
  rescue IO::WaitReadable => e
    unless `which pbpaste`.empty?
      StringIO.new(`pbpaste`)
    else
      STDERR << 'Nothing to do!'
    end
  end

end
