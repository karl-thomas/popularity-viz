class PostsController < ApplicationController 
  before_action :authenticate 
  
  def index
    render json: Post.cards
  end

  def show
    post = Post.find(params[:id])
    render json: post.to_json
  end
  
  private
    def authenticate
      if request.method == "GET"
        authenticate_or_request_with_http_basic do |username, password|
          username == ENV["USERNAME"] && password == ENV["PASSWORD"]
        end
      end
    end
end