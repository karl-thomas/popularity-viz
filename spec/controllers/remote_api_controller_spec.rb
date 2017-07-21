require 'rails_helper'

RSpec.configure {|c| c.before { expect(controller).not_to be_nil }}

describe RemoteApiController do
  RemoteApiController.action_methods.each do |action_method|
    it "#{action_method} responds with status code 200" do
      get action_method.to_sym
      expect(response.status).to be(200)
    end

    # it "renders json out as its response" do

    # end
  end
end