require './lib/mirage/client'
class UserProfile
  extend Mirage::Template::Model

  endpoint '/users'
  http_method :get
  status 200
  content_type 'application/json'
  required_body_content %w(leon davis)

  builder_methods :firstname, :lastname, :age

  def body
    {firstname: firstname, lastname: lastname, age: age}.to_json
  end
end

mirage = Mirage.start
mirage.put UserProfile.new.firstname('leon').lastname('davis').age(30)