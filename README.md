# Automatic Blog

This is the back end and data aggregation of my *Automatic Blog* Idea. A program that writes a blog post for me every two weeks using information from API's of the websites and applications I use the most, such as this one, Github! This is currrently being served at my [personal website](https://github.com/karl-thomas/personal-website), which im currently working on, so go check it out!

## Stack
This project is using 
* Ruby **2.4.1**
* Ruby on Rails **5.1.2**
* Postgresql **9.6.2**

"Why postgres? this seems like a Document model database deal."
I started with MongoDB but Postgresqls JSONB storage is nearly as fast and I get to keep working in relational database. 

Currently in this project there are many api wrappers and within the wrappers several different levels of authentication for querying different things. So as of right now im not listing the ENV variables im needing because there are just so many. If you would like to contribute you can get a hold of me or look through the code to see all the keys that are in use.

Also with all of the API keys, ZERO of them have Write/Update/Delete access to everything outside of spotify playlists.

## Testing
This project relies heavily on these gems for running tests. 
* RSpec **3.6.x**
* VCR **3.x**
* Webmock **3.x**

**Rspec** is the main BDD structure in the spec file.
**VCR** and **Webmock** are only for integration testing, which is most of my tests as most methods are retrieving data from an api. 

I needed a _high_ volume of stubbed api calls, and VCR helps automate that. The first time the tests run it records the requests to JSON files, and in subsequent runs **Webmock** stops the request from happening and **VCR** plays the recorded response for that test.

**Capybara** is also used for some of the tests, but will most likely be phased out. 

## Contributing
Setup 
```
$ git clone https://github.com/karl-thomas/automatic-blog.git

dependencies
$ bundle install 

db setup
$ rails db:create db:migrate

create an AUTO-MATIC POST WOOOOOO
$ rails db:seed

```

I made a note about ENV variables, because there are more than 20, just get a hold of me for them.  
