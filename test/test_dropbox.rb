require 'nwcopy'
require 'minitest/spec'
require 'fileutils'

describe Nwcopy::Dropbox do
  before do
    @dropbox = Nwcopy::Dropbox
    @base = File.expand_path(File.join(File.dirname(__FILE__), '..', 'tmp', 'Dropbox'))
    @nwcopy_base = File.join(@base, 'nwcopy')
    @dropbox.dropbox_base = @base
  end

  describe :with_dropbox do
    before do
      @dropbox.dropbox_base = @base
      FileUtils.mkdir_p @base
      @available = @dropbox.available?
    end

    describe :available? do

      it "should respond positively" do
        @available.must_equal true
      end

      it "should create an nwcopy directory" do
        File.exists?(@nwcopy_base).must_equal true
      end

    end

    describe :time do
      before do
        @testfile = File.join(@nwcopy_base, 'foobar')
      end

      it "should return nil when no files exist" do
        @dropbox.time.must_be_nil
      end

      it "should return the time when files exist" do
        FileUtils.touch(@testfile)
        @dropbox.time.must_equal File.new(@testfile).mtime
      end
    end

    describe :copy do
      before do
        @data = "Bad artists copy. Good artists steal."
        @file = @dropbox.copy @data
      end

      it "should exist" do
        File.exists?(@file).must_equal true
      end

      it "should have the same data" do
        File.new(@file).read.must_equal @data
      end
    end

    describe :paste do
      before do
        @data = "Copy from one, it's plagiarism; copy from two, it's research."
        @file = @dropbox.copy @data
        @pasted = @dropbox.paste
      end

      it "should match the original data" do
        @data.must_equal @pasted
      end
    end

    after do
      FileUtils.rm_rf @base
    end
  end

  describe :without_dropbox do
    describe :available? do
      it "should respond negatively" do
        @dropbox.available?.must_equal false
      end
    end
  end
end
