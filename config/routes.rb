Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root to: 'remote_api#github_profile'

  # github info
  get 'remote_api/github_profile', to: 'remote_api#github_profile'
  get 'remote_api/recent_repos', to: 'remote_api#recent_repos'
  get 'remote_api/recent_commits', to: 'remote_api#recent_commits'

  # linkedin info
  get 'remote_api/linkedin_profile', to: 'remote_api#linkedin_profile'
end
