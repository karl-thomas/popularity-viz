Rails.application.routes.draw do

  get '/posts', to: 'posts#index' 
  get '/posts/:id', to: 'posts#show'
  # i may need these routes to get some anciliary data  
  match '/posts/:id' =>'posts#show', via: :options
  match '/posts' => 'posts#index', via: :options

  # root 'spotify#index'
  # get '/auth/spotify/callback', to: 'spotify#spotify'
  
  # # github info
  # get 'github/profile', to: 'github#profile'
  # get 'github/recent_repos', to: 'github#recent_repos'
  # get 'github/recent_commits', to: 'github#recent_commits'

  # linkedin info
  # get 'linkedin/profile', to: 'linkedin#profile'

  # twitter info
  # get 'twitter/profile', to: 'twitter#profile'
  # get 'twitter/recent_tweets', to: 'twitter#recent_tweets'
  # get 'twitter/recent_replies', to: 'twitter#recent_replies'
  # get 'twitter/recent_mentions', to: 'twitter#recent_mentions'
  # get 'twitter/recent_friends', to: 'twitter#recent_friends'
  # get 'twitter/recent_followers', to: 'twitter#recent_followers'
  # get 'twitter/recent_favorites', to: 'twitter#recent_favorites'
  # get 'twitter/formatted_profile', to: 'twitter#formatted_profile'

end