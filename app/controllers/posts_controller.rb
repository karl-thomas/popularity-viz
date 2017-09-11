class PostsController < ApplicationController 

  def index
    post = Post.first
    render json: post.as_json
  end
end