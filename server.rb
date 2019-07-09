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

get '/' do
  puts 'running'
  erb :home
end

get '/signup' do
  @user = User.new
  erb :signup
end

post '/signup' do
  @user = User.new(params)
  if @user.save
    p "#{@user.first_name} was saved in the database!"
    redirect '/thanks'
  end
end

get '/thanks' do
  erb :thanks
end

get '/login' do
  if session[:user_id]
    redirect '/'
  else
    erb :login
  end
end

post '/login' do
  given_password = params['password']
  user = User.find_by(email: params['email'])
  if user
    if user.password == given_password
      p "User authenticated successful"
      session[:user_id] = user.id
      redirect '/'
    else
      p "Invalid email or password"
    end
  end
end

post '/logout' do
  session.clear
  p "user logged out successfully"
  redirect '/'
end
