require 'rails_helper' 

RSpec.describe Repo::PullRequests::Pull do
  let(:repo) { GithubAdapter.new.owned_repos.first }
  let(:pull) { repo.pull_requests.pulls[0]}

  describe "on initialization", :vcr do
    describe "repo" do
      it "is readable" do
        expect(pull.repo).to_not raise_error
      end

      it "returns an instance of string" do
        expect(pull.repo).to be_an_instance_of String
      end
    end

    describe "number " do
      it "is readable" do
        expect(pull.number ).to_not raise_error
      end

      it "returns an instance of integer" do
        expect(pull.number).to be_an_instance_of Integer
      end
    end

    describe "state" do
      it "is readable" do
        expect(pull.state).to_not raise_error
      end
      it "returns an instance of string" do
        expect(pull.state).to be_an_instance_of String
      end
    end

    describe "title" do
      it "is readable" do
        expect(pull.title).to_not raise_error
      end

      it "returns an instance of string" do
        expect(pull.title).to be_an_instance_of String
      end
    end

    describe "body" do
      it "is readable" do
        expect(pull.body).to_not raise_error
      end

      it "returns an instance of string" do
        expect(pull.body).to be_an_instance_of string
      end
    end

    describe "created_at" do
      it "is readable" do
        expect(pull.created_at).to_not raise_error
      end

      it "returns an instance of Date" do
        expect(pull.created_at).to be_an_instance_of Date
      end
    end

    describe "closed_at" do
      it "is readable" do
        expect(pull.closed_at).to_not raise_error
      end

      it "returns an instance of date" do
        expect(pull.closed_at).to be_an_instance_of Date
      end
    end

    describe "client" do
      it "is readable" do
        expect(pull.client).to_not raise_error
      end

      it "returns an instance of Octokit::Client" do
        expect(pull.client).to be_an_instance_of Ockokit::Client
      end
    end
  end

  describe "recent?" do
    it "returns a boolean" do
      expect(pull.recent?).to be(true).or(false)
    end

  end

  describe "closed?" do
    it "returns a boolean" do
      expect(pull.closed?).to be(true).or(false)
    end

    it "returns true when the pull_request is closed" do
      expect(pull.closed?).to be true
    end
  end

  describe "recently_created?" do
    it "returns a boolean" do
      expect(pull.recently_created?).to be(true).or(false)
    end
  end

  describe "recently_closed?" do
    it "returns a boolean" do
      expect(pull.recently_closed?).to be(true).or(false)
    end
  end


end