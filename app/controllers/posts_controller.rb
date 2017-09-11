class PostsController < ApplicationController 

  def index
    post = Post.first
    relevant_data = post.as_json.delete_if {|k| k == '_id'}
    render json: relevant_data
  end
end