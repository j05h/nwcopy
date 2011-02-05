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
    data = copy_data_from_options

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
    data = paste_data_from_options
    unavailable = []
    plugins.each do |plugin|
      if plugin.available?
        if clipboard = plugin.paste(data)
          `echo "#{clipboard}" | pbcopy` unless `which pbcopy`.empty?
          return clipboard
        end
      else
        STDERR << plugin.unavailable_message + "\n"
      end
    end
  end

  private
  def self.paste_data_from_options
    if ARGV.include? '--help'
      help
    else
      ARGV.shift
    end
  end

  def self.copy_data_from_options
    if ARGV.empty?
      nodata = ARGF.read_nonblock(1) rescue true
    else
      nodata = false
    end

    if nodata || ARGV.include?('--help')
      help
    elsif ARGV.include?('-p')
      StringIO.new `pbpaste`
    else
      ARGF
    end
  end

  def self.help
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
    puts '  nwpaste <hash>'
    puts '    Pastes the provided hash from nwcopy.net'
    puts
    exit
  end
end
