require "sinatra"
require "sinatra/activerecord"
enable :sessions

class User < ActiveRecord::Base
end

# LOCAL
# ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "./db.sqlite3")
# HEROKU
require "active_record"
ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])

class User
  attr_accessor :email, :password, :id
  def initialize(email, password)
    @email = email
    @password = password
  end

  def valid?
    if (@email != '' && @password != '' && @password.length > 7)
      return true
    end
  end

  def save
    $db.execute("INSERT INTO users (email, password)
    VALUES ('#{@email}', '#{@password}');")
    return true
  end

  def self.all
    @all = $db.execute("SELECT * FROM users;")
    return @all
  end

   def self.find(id)
     @user = $db.execute("SELECT * FROM users WHERE id = '#{id}'")
     return @user
   end

  def delete?(id)
    @user = $db.execute("DELETE FROM users WHERE id = '#{id}'")
    return @user
end

get "/" do
  erb :home
end

get "/signup" do
  erb :signup
end

get "/users" do
  @users = User.all
  erb :users
end

get '/user/:id' do

end

post "/signup" do
  p "POST request recieved"
  p params
  @user = User.new(params[@email], params[@password])
  if @user.valid?
    @user.save
    redirect "/thank-you", 301
  else
    puts 'This user is missing information'
  end
end

get "/thank-you" do
  erb :thanks
end
