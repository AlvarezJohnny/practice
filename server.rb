require "sinatra"
require "sinatra/activerecord"
enable :sessions

class User < ActiveRecord::Base
end

class Post < ActiveRecord::Base
end

if ENV['RACK_ENV']
  ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
else
  ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "./db.sqlite3")
end

# LOCAL
# ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: "./db.sqlite3")
# HEROKU
require "active_record"
# ActiveRecord::Base.establish_connection(ENV["DATABASE_URL"])

get '/' do
  @all_posts = Post.last(20)
  for letter in @all_posts
     if letter
       letter.title
       letter.content
       letter.image_url
       letter.user_id
     else
     end
   end
  erb :home
end

get '/signup' do
  @user = User.new

  erb :signup
end

post '/signup' do
  @user = User.new(params)
  if @user.save
    if @user == nil
      @user.destroy
    else
      redirect '/thanks'
    end
  end
end

post '/delete_user' do
  bye = User.find(session[:user].id)
  bye.destroy
  redirect '/login'
end

get '/thanks' do
  erb :thanks
end

get '/login' do
  if session[:user_id]
    redirect '/profile'
  else
    erb :login
  end
end

post '/login' do
  emails = params[:email]
  given_password = params['password']
  user = User.find_by(email: params['email'])
  if user
    if user.password == given_password
      p "User authenticated successful"
      session[:user] = user
      redirect '/profile'
    else
      p 'Incorrect Username or Password'
      redirect '/incorrect'
    end
  elsif user == nil
    redirect 'login'
  end
end

get '/incorrect' do
  erb :incorrect
end

post '/logout' do
  session.clear
  p "user logged out successfully"
  redirect '/'
end

get '/account' do
  if session[:user]
    erb :account
  else
    redirect '/'
  end
end


get '/profile' do
  if session[:user]
    @publish = Post.where(user_id: session[:user].id)
  else
  end
  erb :profile
end

post '/create_post' do
  post = Post.new(title: params[:title], content: params[:content], image_url: params[:image_url], user_id: session[:user].id)
  post.save
  redirect '/profile'
end

post '/delete_post' do
  post = Post.find_by(params[:id])
  post.destroy
  redirect '/profile'
end
