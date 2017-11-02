# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'pry-rails'
ENV["RAILS_ENV"] ||= 'test'
require 'spec_helper'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'capybara/rails'
require 'webmock/rspec'
# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
# ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!
end

RSpec.configure do |config|
  config.raise_errors_for_deprecations!
  config.before(:all) do
    @test_repo = "#{github_login}/#{test_github_repository}"
    @test_repo_id = test_github_repository_id
  end
end

require 'vcr'
VCR.configure do |c|
  c.configure_rspec_metadata!
  c.filter_sensitive_data("<GITHUB_LOGIN>") do
    github_login
  end
  c.filter_sensitive_data("<GITHUB_PASSWORD>") do
    test_github_password
  end
  c.filter_sensitive_data("<<ACCESS_TOKEN>>") do
    test_github_token
  end
  c.filter_sensitive_data("<GITHUB_CLIENT_ID>") do
    test_github_client_id
  end
  c.filter_sensitive_data("<GITHUB_CLIENT_SECRET>") do
    test_github_client_secret
  end
  c.define_cassette_placeholder("<GITHUB_TEST_REPOSITORY>") do
    test_github_repository
  end
  c.define_cassette_placeholder("<GITHUB_TEST_ORG_TEAM_ID>") do
    "10050505050000"
  end


  c.ignore_request do |request|
    !!request.headers['X-Vcr-Test-Repo-Setup']
  end

  c.ignore_request do |request|
    query = URI(request.uri).query
    if query
      (query).include?('since')
    end
  end

  c.default_cassette_options = {
    :serialize_with             => :json,
    # TODO: Track down UTF-8 issue and remove
    :preserve_exact_body_bytes  => true,
    :decode_compressed_response => true,
    :record                     => ENV['TRAVIS'] ? :none : :once
  }
  c.cassette_library_dir = 'spec/cassettes'
  c.hook_into :webmock
end

def delete_test_repo
  begin
    oauth_client.delete_repository @test_repo
  rescue Octokit::NotFound
  end
end

def github_login
  ENV.fetch 'GITHUB_USERNAME', 'api-padawan'
end

def test_github_password
  ENV.fetch 'GITHUB_PASSWORD', 'wow_such_password'
end

def test_github_token
  ENV.fetch 'GITHUB_TOKEN', 'x' * 40
end

def test_github_client_id
  ENV.fetch 'GITHUB_CLIENT_ID', 'x' * 21
end

def test_github_client_secret
  ENV.fetch 'GITHUB_CLIENT_SECRET', 'x' * 40
end

def test_github_repository
  ENV.fetch 'OCTOKIT_TEST_GITHUB_REPOSITORY', 'api-sandbox'
end

def test_github_repository_id
  ENV.fetch 'OCTOKIT_TEST_GITHUB_REPOSITORY_ID', 20_974_780
end


def stub_delete(url)
  stub_request(:delete, github_url(url))
end

def stub_get(url)
  stub_request(:get, github_url(url))
end

def stub_head(url)
  stub_request(:head, github_url(url))
end

def stub_patch(url)
  stub_request(:patch, github_url(url))
end

def stub_post(url)
  stub_request(:post, github_url(url))
end

def stub_put(url)
  stub_request(:put, github_url(url))
end

def fixture_path
  File.expand_path("../fixtures", __FILE__)
end

def fixture(file)
  File.new(fixture_path + '/' + file)
end

def auth_client_params
    "client_id=#{test_github_client_id}&client_secret=#{test_github_client_secret}"
end

def github_url(url)
  return url if url =~ /^http/

  url = File.join(Octokit.api_endpoint, url)
  uri = Addressable::URI.parse(url)
  uri.path.gsub!("v3//", "v3/")

  
end

def two_weeks_ago
  2.weeks.ago.strftime("%Y-%m-%d")
end

def basic_github_url(path, options = {})
  url = File.join(Octokit.api_endpoint, path)
  uri = Addressable::URI.parse(url)
  uri.path.gsub!("v3//", "v3/")

  uri.user = options.fetch(:login, test_github_login)
  uri.password = options.fetch(:password, test_github_password)

  uri.to_s
end

def basic_auth_client(login = test_github_login, password = test_github_password )
  client = Octokit.client
  client.login = test_github_login
  client.password = test_github_password

  client
end

def time_stubs
  a = [[1, 1, 1, 1], [2, 2, 2, 2], [3, 3, 3, 3], [4, 4, 4, 4]]
  a.map {|row| row.map {|time| time.days.ago } }
end

def since
  "&since=#{two_weeks_ago}"
end