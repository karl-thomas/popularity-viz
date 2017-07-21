require 'rails_helper'

RSpec.configure {|c| c.before { expect(controller).not_to be_nil }}

describe RemoteApiController do
  # RemoteApiController.action_methods.each do |action_method|
  #   p action_method
  #   describe "GET ##{action_method}" do
  #     it "responds with status code 200" do
  #       get action_method.to_sym
  #       puts response
  #       expect(response.status).to eq(200)
  #     end

  #     it "successfully calls an api" do
  #       get action_method
  #       puts response
  #     end

  #     it "renders json out as its response" do
  #       get action_method.to_sym
  #       expect(response.content_type).to eq("application/json")
  #     end
  #   end
  # end

  it "successfully calls an api" do
    get :github_profile
      puts api_reponse = assigns(:api_reponse)
      puts response.class
      puts response.body
    end
end