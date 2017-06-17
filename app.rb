require 'sinatra'
require 'data_mapper'
DataMapper.setup(:default,'sqlite:///'+Dir.pwd+'/project.db')
class User
	include DataMapper::Resource
	property :id, Serial
	property :email, String
	property :password, String
end
DataMapper.finalize
DataMapper.auto_upgrade!
enable :sessions
get '/' do
	if session[:user_id].nil?
		return redirect '/signin'
	end
	erb :index, locals:{user_id:session[:user_id]}
end
get '/signout' do
	session[:user_id]=nil
	return redirect '/'
end
get '/signin' do
	erb:signin
end
post '/signin' do
	email=params["email"]
	password=params["password"]
	user=User.all(email:email).first
	if user.nil?
		return redirect '/signup'
	else
		if user.password==password
			session[:user_id]=user.id
			return redirect '/'
		else
			return redirect '/signin'
		end
	end
	redirect '/signin'
end
get '/signup' do
	erb :signup
end
post '/signup' do
	email=params["email"]
	password=params["password"]
	user=User.all(email: email).first
	if user
		return redirect '/signup'
	else
		user=User.new
		user.email=email
		user.password=password
		user.save
		session[:user_id]=user.id
		return redirect '/'
	end
end