require 'rails_helper'

RSpec.configure {|c| c.before { expect(controller).not_to be_nil }}

describe RemoteApiController do

  context "github api actions" do

    describe "GET #github_profile" do
      before { get :github_profile }

      it "assigns the result of an adapter function as api_reponse" do
        api_response = assigns(:api_response)
        expect(api_response).to_not be(nil)
      end

      it "responds with status code 200" do
        expect(response.status).to eq(200)
      end

      it "successfully calls an api" do
        api_response = assigns(:api_response)
        expect(api_response.headers["status"]).to include("200")
      end

      it "renders json out as its response" do
        expect(response.content_type).to eq("application/json")
      end

    end

    describe "GET #recent_repos" do
      before { get :recent_repos }

      it "assigns the result of an adapter function as api_reponse" do
        api_response = assigns(:api_response)
        expect(api_response).to_not be(nil)
      end

      it "responds with status code 200" do
        expect(response.status).to eq(200)
      end

      it "successfully calls an api" do
        api_response = assigns(:api_response)
        expect(api_response.headers["status"]).to include("200")
      end

      it "renders json out as its response" do
        expect(response.content_type).to eq("application/json")
      end

    end

    pending describe "GET #recent_commits" do
      before { get :recent_commits}
      
      it "assigns the result of an adapter function as api_reponse" do
        api_response = assigns(:api_response)
        expect(api_response).to_not be(nil)
      end

      it "responds with status code 200" do
        expect(response.status).to eq(200)
      end

      it "successfully calls an api" do
        api_response = assigns(:api_response)
        expect(api_response.headers["status"]).to include("200")
      end

      it "renders json out as its response" do
        expect(response.content_type).to eq("application/json")
      end
    end
  end

  context "linkedin api actions" do

    describe "GET #linkedin_profile" do
      before { get :linkedin_profile }

      it "assigns the result of an adapter function as api_reponse" do
        api_response = assigns(:api_response)
        expect(api_response).to_not be(nil)
      end

      it "responds with status code 200" do
        expect(response.status).to eq(200)
      end

      it "successfully calls an api" do
        api_response = assigns(:api_response)
        expect(api_response.response.code).to include("200")
      end

      it "renders json out as its response" do
        expect(response.content_type).to eq("application/json")
      end

    end
  end
end
