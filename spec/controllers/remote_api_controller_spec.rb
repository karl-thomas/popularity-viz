require 'rails_helper'

RSpec.configure {|c| c.before { expect(controller).not_to be_nil }}

describe RemoteApiController do
  context "github api actions" do
    describe "GET #github_profile" do
      it "assigns the result of an adapter function as api_reponse" do
        get :github_profile
        api_response = assigns(:api_response)
        expect(api_response).to_not be(nil)
      end

      it "responds with status code 200" do
        get :github_profile
        puts response
        expect(response.status).to eq(200)
      end

      pending it "successfully calls an api" do
        get :github_profile
        puts response
      end

      it "renders json out as its response" do
        get :github_profile
        expect(response.content_type).to eq("application/json")
      end
    end

    describe "GET #recent_repos" do
        
      it "assigns the result of an adapter function as api_reponse" do
        get :recent_repos
        api_response = assigns(:api_response)
        expect(api_response).to_not be(nil)
      end

      it "responds with status code 200" do
        get :recent_repos
        puts response
        expect(response.status).to eq(200)
      end

      it "successfully calls an api" do
        get :recent_repos
        puts response
      end

      it "renders json out as its response" do
        get :recent_repos
        expect(response.content_type).to eq("application/json")
      end

    end

    pending describe "GET #recent_commits" do
      
      it "assigns the result of an adapter function as api_reponse" do
        get :recent_commits
        api_response = assigns(:api_response)
        expect(api_response).to_not be(nil)
      end

      it "responds with status code 200" do
        get :recent_commits
        puts response
        expect(response.status).to eq(200)
      end

      pending it "successfully calls an api" do
        get :recent_commits
        puts response
      end

      it "renders json out as its response" do
        get :recent_commits
        expect(response.content_type).to eq("application/json")
      end
    end
  end

  context "linkedin api actions" do
    describe "GET #linkedin_profile" do
      it "assigns the result of an adapter function as api_reponse" do
        get :linkedin_profile
        api_response = assigns(:api_response)
        expect(api_response).to_not be(nil)
      end

      it "responds with status code 200" do
        get :linkedin_profile
        puts response
        expect(response.status).to eq(200)
      end

      pending it "successfully calls an api" do
        get :linkedin_profile
        puts response
      end

      it "renders json out as its response" do
        get :linkedin_profile
        expect(response.content_type).to eq("application/json")
      end
    end
  end
end