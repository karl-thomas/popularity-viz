Rails.application.routes.draw do

  root to: 'twitter#recent_favorites'

  # github info
  get 'remote_api/github_profile', to: 'remote_api#github_profile'
  get 'remote_api/recent_repos', to: 'remote_api#recent_repos'
  get 'remote_api/recent_commits', to: 'remote_api#recent_commits'

  # linkedin info
  get 'remote_api/linkedin_profile', to: 'remote_api#linkedin_profile'

  # twitter info
  get 'twitter/profile', to: 'twitter#profile'
  get 'twitter/recent_tweets', to: 'twitter#recent_tweets'
  get 'twitter/recent_replies', to: 'twitter#recent_replies'
  get 'twitter/recent_friends', to: 'twitter#recent_friends'
  get 'twitter/recent_followers', to: 'twitter#recent_followers'
  get 'twitter/recent_favorites', to: 'twitter#recent_favorites'

end