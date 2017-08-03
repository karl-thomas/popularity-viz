class LinkedinController < ApplicationController
  before_action :set_linkedin_adapter
  
  def linkedin_profile
    @api_response = @linkedin_adapter.profile
    render json: @api_response
  end

  private 
  
    def set_linkedin_adapter
      @linkedin_adapter = LinkedinAdapter.new
    end
end
