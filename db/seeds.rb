# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

g = GithubAdapter.new
s = SpotifyAdapter.new
t = TwitterAdapter.new

insight_hash = {github: g, spotify: s, twitter: t}
i = Insight.new(insight_hash)

g_record = g.aggregate_data_record
s_record = s.aggregate_data_record
t_record = t.aggregate_data_record
total_insights = i.total_insights

post_hash = {github_record: g_record, spotify_record: s_record, twitter_record: t_record, insights: total_insights}

post = Post.new(post_hash)

# just incase i need to do somehting in betwwen init and save

post.save