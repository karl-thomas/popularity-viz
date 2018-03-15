class ApplicationController < ActionController::Base
  # the for API-style rails apps
  protect_from_forgery with: :null_session
end
