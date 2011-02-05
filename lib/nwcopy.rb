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
    data = data_from_options

    unavailable = []
    plugins.each do |plugin|
      if plugin.available?
        return plugin.copy data
      else
        STDERR << plugin.unavailable_message + "\n"
      end
    end
  end

  def self.paste
    data_from_options
    unavailable = []
    plugins.each do |plugin|
      if plugin.available?
        if clipboard = plugin.paste
          `echo "#{clipboard}" | pbcopy` unless `which pbcopy`.empty?
          return clipboard
        end
      else
        STDERR << plugin.unavailable_message + "\n"
      end
    end
  end

  private
  def self.data_from_options
    if ARGV.empty?
      nodata = ARGF.read_nonblock(1) rescue true
    else
      nodata = false
    end

    if nodata || ARGV.include?('--help')
      puts 'nwcopy: network copy and paste.'
      puts 'Sign up at http://nwcopy.net.' unless Nwcopy::Client.available?
      puts "nwcopy.net account: #{Nwcopy::Client.credentials.first}" if Nwcopy::Client.available? rescue ''
      puts
      puts '  nwcopy <file>'
      puts '    Copies the file to nwcopy.net'
      puts '  nwcopy -p'
      puts '    Copies the contents of the clipboard (MacOS) to nwcopy.net'
      puts '  command | nwcopy'
      puts '    Copies the results of the piped command to nwcopy.net'
      puts
      puts '  nwpaste'
      puts '    Pastes the last thing you copied to nwcopy.net'
      puts '    If it is a file, it will be put into that file name.'
      puts '    Any piped input or clipboard will be printed to STDOUT.'
      puts
      exit
    elsif ARGV.include?('-p')
      StringIO.new `pbpaste`
    else
      ARGF
    end
  end
end
