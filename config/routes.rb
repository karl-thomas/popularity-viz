Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'remote_api#github_profile'
  get 'remote_api/github_profile', to: 'remote_api#github_profile'
  get 'remote_api/github_repos', to: 'remote_api#github_repos'
end
