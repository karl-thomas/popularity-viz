class GithubProfileAdapter < GithubAdapter

  def profile
    @profile ||= self.client.user(self.user)
  end

  def data
    {
      public_repos: profile.public_repos,
      public_gists: profile.public_gists,
      followers: profile.followers,
      following: profile.following
    }
  end

  def starred_repos
    profile.starred(self.user)
  end

  def recent_starred_repos
    repos = self.starred_repos
    binding.pry
  end
end