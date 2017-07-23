require 'rails_helper'

RSpec.configure {|c| c.before { expect(controller).not_to be_nil }}

describe RemoteApiController do

  context "github api actions" do

    describe "GET #github_profile" do
      before { get :github_profile }

      it "assigns an instance of github adapter for requests" do
        github_adapter = assigns(:github_adapter)
        expect(github_adapter).to be_an_instance_of(GithubAdapter)
      end

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

      it "assigns an instance of github adapter for requests" do
        github_adapter = assigns(:github_adapter)
        expect(github_adapter).to be_an_instance_of(GithubAdapter)
      end

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

      it "assigns an instance of github adapter for requests" do
        github_adapter = assigns(:github_adapter)
        expect(github_adapter).to be_an_instance_of(GithubAdapter)
      end
      
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

      it "assigns an instance of linkedin_adapter for requests" do
        linkedin_adapter = assigns(:linkedin_adapter)
        expect(linkedin_adapter).to be_an_instance_of(LinkedinAdapter)
      end

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
