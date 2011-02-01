require 'test_helper'

describe Nwcopy::Gist do

  before do
    @gist = Nwcopy::Gist
    @gists = {"gists" => [
      {"public" => true,"created_at" => "2010/11/11 15:20:55 -0800","owner" => "j05h","files" => ["distance.rb"],
        "description" => "Haversine formula in ruby", "repo" => "673425"},
      {"public" => true,"created_at" => "2010/09/28 12:26:29 -0700","owner" => "j05h","files" => ["random_string.rb"],
        "description" => nil, "repo" => "601616"},
      {"public" => true,"created_at" => "2010/07/09 15:01:22 -0700","owner" => "j05h","files" => ["gistfile1.rb"],
        "description" => nil,"repo" => "470131"}]}
  end

  describe :with_github do
    before do
      @mock = MiniTest::Mock.new
      @mock.expect :auth, {"foo" => "bar"}
      @gist.gist = @mock
    end

    describe :available do
      it 'should be' do
        @gist.available?.must_equal true
      end
    end

    describe :time do
      before do
        @mock.expect :list, @gists
      end

      it "should return the latest time" do
        @gist.time.must_equal Time.parse(@gists["gists"].first["created_at"])
      end
    end

    describe :copy do
      before do
        @mock.expect :write, "someurl", [String, true]
      end

      it "should return a url response" do
        @gist.copy("To all good things an end must come.").must_equal "someurl"
      end
    end

    describe :paste do
      before do
        @mock.expect :list, @gists
        @mock.expect :read, "Wassup?", [@gists["gists"].first["repo"]]
      end

      it "should return appropriate data" do
        @gist.paste.must_equal "Wassup?"
      end
    end
  end


  describe :without_github do
    before do
      @mock = MiniTest::Mock.new
      @mock.expect :auth, {}
      @gist.gist = @mock
    end

    describe :available do
      it 'should not be' do
        @gist.available?.must_equal false
      end
    end
  end
end
