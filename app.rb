require 'sinatra'
require 'data_mapper'
DataMapper.setup(:default,'sqlite:///'+Dir.pwd+'/project.db')
class User
	include DataMapper::Resource
	property :id, Serial
	property :email, String
	property :password, String
end
class Tweet
	include DataMapper::Resource
	property :id, Serial
	property :email, String
	property :text, String
	property :like, Integer
	property :unlike, Integer
	property :time, DateTime
end
class Comment
    include DataMapper::Resource
    property :id, Serial
    property :text, String
    property :commentweet, Integer
    property :commentor, String
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
post '/tweet' do
    email=User.get(session[:user_id]).email
    tweet=Tweet.new
    tweet.email=email
    tweet.text=params["text"]
    tweet.like=0
    tweet.unlike=0
    tweet.time=Time.now
    tweet.save
    return redirect '/'
end
post '/like' do
t=params["like"].to_i
tweet=Tweet.get(t)
tweet.like=tweet.like+1
tweet.save
return redirect '/'

end
post '/unlike' do
	 t=params["unlike"].to_i
     tweet=Tweet.get(t)
     tweet.unlike=tweet.unlike+1
     tweet.save
	return redirect '/'
end
id=0
get '/getcomment' do
	erb :comment, locals:{tweet_id:id}
end
post '/comment' do
	 id=params["comment"].to_i
	 return redirect '/getcomment'
end
post '/postcomment' do
	puts "helloworld"
     text=params["comment"]
     commentor=User.get(session[:user_id]).email
     commentweet=params["comment_id"].to_i
     comment=Comment.new
     comment.commentor=commentor
     comment.text=text
     comment.commentweet=commentweet
     comment.save
     return redirect '/getcomment'
end
