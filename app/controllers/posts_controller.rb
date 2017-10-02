class PostsController < ApplicationController 

  def index
    render json: Post.cards
  end

  def show
    post = Post.find(params[:id])
    render json: post.to_json
  end
end