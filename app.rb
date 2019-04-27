# frozen_string_literal: true

require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra-websocket'
require 'json'
require 'date'

require_relative 'model/user'

set :environment, :production

set :server, 'thin'
set :sockets, []

use Rack::Session::Cookie, key: 'rack.session', expire_after: 1.hours
# enable :sessions
# set :session_secret, "My session secret"
# set :root, File.dirname(__FILE__)

Mongoid.configure do |config|
  config.clients.default = {
    hosts: ['localhost:27017'],
    database: 'chat_app'
  }

  config.log_level = :warn
end

class ChatRoom
  @room_url
  @room_name

  def initialize(room_url, room_name)
    @room_url = room_irl
    @room_name = room_name
  end
end

get '/' do
  redirect '/login'
end

get '/login' do
  p session[:user_id]
  erb :login
end

post '/user_authentication' do
  p 'authenticating...'
  user = User.authenticate(params[:name], params[:password])
  if user
    session[:user_id] = user._id
    redirect '/chat'
  else
    redirect '/login'
  end
end

get '/registration' do
  # session[:user_id] ||= nil
  erb :registration
end

post '/user_registration' do
  redirect '/registration' if params[:password] != params[:password_confirm]

  user = User.new(name: params[:user_name])
  user.encrypt_password(params[:password])
  if user.save!
    redirect '/login'
  else
    redirect '/registration'
  end
end

post '/create_chatroom' do
  p 'create_chatroom'
end

get '/chat' do
  p session[:user_id]
  @user = User.where(_id: session[:user_id]).first
  if @user
    session[:user_name] = @user[:name]
    p @user[:name]
    p session[:user_name]
    # session[:user_name] = user
    erb :chat
  else
    redirect `/login`
  end
end

# favicon表示用
get '/favicon.ico' do
  p 'send icon'
  send_file 'favicon.ico'
end

get '/websocket' do
  if request.websocket?
    request.websocket do |ws|
      ws.onopen do
        login_user_name = {}
        login_user_name[:login_user_name] = session[:user_name]
        ws.send(login_user_name.to_json)
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        settings.sockets.each do |s|
          result = JSON.parse(msg)
          result[:user_name] = session[:user_name]
          s.send(result.to_json)
        end
        # settings.sockets[0].send("hogehoge")
      end
      ws.onclose do
        settings.sockets.delete(ws)
      end
    end
  end
end
