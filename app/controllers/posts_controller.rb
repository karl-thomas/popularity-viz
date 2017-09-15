class PostsController < ApplicationController 

  def index
    posts = Post.all
    relevant_data = posts.map { |p| p.as_json }  
    render json: relevant_data
  end

  def show
    post = Post.find(params[:id])
    relevant_data = post.as_json.delete_if {|k| k == '_id'}
    render json: relevant_data
  end
end