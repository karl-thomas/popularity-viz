class PostsController < ApplicationController 

  def index
    posts = Post.all
    
    # convert posts to json
    relevant_data = posts.map(&:to_json)
    
    render json: relevant_data
  end

  def show
    post = Post.find(params[:id])
    render json: post.to_json
  end
end