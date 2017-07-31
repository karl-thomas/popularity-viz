class LinkedinAdapter
  include HTTParty
  base_uri 'https://api.linkedin.com'

  attr_reader :user

  def initialize
    @auth = {Authorization: ENV['LINKEDIN_ACCESS_TOKEN']}
    @options = {format: 'json'}
    @user = ENV['LINKEDIN_USER']
  end

  def profile
    profile_request = "/v1/people/~:(id,first-name,last-name,headline,picture-url,industry,num-connections,summary,current-share,specialties,positions:(id,title,summary,start-date,end-date,is-current,company:(id,name,type,size,industry,ticker)),educations:(id,school-name,field-of-study,start-date,end-date,degree,activities,notes),associations,interests,num-recommenders,date-of-birth,publications:(id,title,publisher:(name),authors:(id,name),date,url,summary),patents:(id,title,summary,number,status:(id,name),office:(name),inventors:(id,name),date,url),languages:(id,language:(name),proficiency:(level,name)),skills:(id,skill:(name)),certifications:(id,name,authority:(name),number,start-date,end-date),courses:(id,name,number),recommendations-received:(id,recommendation-type,recommendation-text,recommender),honors-awards,three-current-positions,three-past-positions,volunteer)" 
       
    self.class.get(profile_request + "?oauth2_access_token=#{@auth[:Authorization]}", query: @options)
  end
end

# == get all info, hopefully
#https://api.linkedin.com/