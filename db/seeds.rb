
g = GithubAdapter.new

s = SpotifyAdapter.new

t = TwitterAdapter.new

g_record = g.aggregate_data_record

s_record = s.aggregate_data_record

t_record = t.aggregate_data_record

post_hash = { github_record: g_record, spotify_record: s_record, twitter_record: t_record}
post = Post.new(post_hash)


post.save