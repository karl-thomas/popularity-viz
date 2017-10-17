# Automatic Blog

This is the back end and data aggregation of an Automatic Blog. A program that writes a blog post for me every two weeks using information from API's of the websites and applications I use the most, such as this one, Github! This is currrently being served at my [personal website](https://github.com/karl-thomas/personal-website), which im currently working on, so go check it out!

## Stack and Setup
This project is using 
* Ruby 2.4.1
* Ruby on Rails 5.1.2
* Postgresql 9.6.2

"Why postgres? this seems like a Document model database deal."
I started with MongoDB but Postgresqls JSONB storage is nearly as fast and I get to keep working in relational database. 

To work on this project you'll need access keys to Spotify, Github, and Twitter as of right now. 
