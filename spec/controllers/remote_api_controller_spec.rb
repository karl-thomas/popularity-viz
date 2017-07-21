require 'rails_helper'

RSpec.configure {|c| c.before { expect(controller).not_to be_nil }}

describe RemoteApiController do
  RemoteApiController.action_methods.each do |action_method|
    p action_method
    describe "GET ##{action_method}" do
    it "responds with status code 200" do
      get action_method.to_sym
      puts response
      expect(response.status).to eq(200)
    end

    it "renders json out as its response" do
      get action_method.to_sym
      expect(response.content_type).to eq("application/json")
    end
    end
  end
end