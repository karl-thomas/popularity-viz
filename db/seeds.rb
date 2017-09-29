logger = ActiveSupport::TaggedLogging.new(Logger.new(STDOUT))
logger.info "initializing github adapter"
g = GithubAdapter.new

logger.info "initializing spotify adapter"
s = SpotifyAdapter.new

logger.info "initializing twitter adapter"
t = TwitterAdapter.new

logger.info "retrieving api data from github"
g_record = g.aggregate_data_record

logger.info "retrieving api data from spotify"
s_record = s.aggregate_data_record

logger.info "retrieving api data from twitter"
t_record = t.aggregate_data_record

post_hash = { github_record: g_record, spotify_record: s_record, twitter_record: t_record}
logger.info "creating new post"
post = Post.new(post_hash)


logger.info "saving post"
post.save