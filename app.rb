# frozen_string_literal: true

require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra-websocket'
require 'json'
require 'date'
require 'securerandom'

require_relative 'model/user'

set :environment, :production

set :server, 'thin'
set :sockets, []
set :chat_rooms, {}

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
  @room_members

  def self.create_random_string
    SecureRandom.urlsafe_base64
  end

  def initialize(room_name)
    @room_url = ChatRoom.create_random_string
    @room_name = room_name
    @room_members = {}
  end

  attr_reader :room_name
  attr_reader :room_url
  attr_accessor :room_members
end

get '/' do
  redirect '/login'
end

get '/login' do
  # p session[:user_id]
  erb :login
end

post '/user_authentication' do
  p 'authenticating...'
  user = User.authenticate(params[:name], params[:password])
  if user
    session[:user_id] = user._id
    redirect '/room_select'
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

get '/room_select' do
  if session[:user_id].nil?
    redirect '/login'
  else
    erb :room_select
  end
end

post '/list_chatrooms' do
  if session[:user_id].nil?
    redirect '/login'
  else
    list_chatrooms = {}
    list_chatrooms[:chat_rooms] = []
    settings.chat_rooms.each_value do |value|
      p value
      tmp_hash = { room_url: value.room_url, room_name: value.room_name }
      list_chatrooms[:chat_rooms] << tmp_hash
      # list_chatrooms[:chat_rooms] = value.room_url
      # list_chatrooms[:room_name] = value.room_name
    end
    # p list_chatrooms
    content_type :json
    JSON.generate(list_chatrooms)
  end
end

post '/create_chatroom' do
  p 'create_chatroom'

  chat_room = ChatRoom.new(params[:name])
  settings.chat_rooms[chat_room.room_url] = chat_room
  # params[:name]
  p chat_room.room_name
  p chat_room.room_url
  p settings.chat_rooms.length
  chat_room.room_url
end

get '/chat/:room_url' do
  p params[:room_url]
  p session[:user_id]
  @user = User.where(_id: session[:user_id]).first
  if @user
    session[:user_name] = @user[:name]
    p @user[:name]
    p session[:user_name]
    if settings.chat_rooms.key?(params[:room_url])
      p 'exist'
      session[:room_url] = params[:room_url]
      erb :chat
    else
      p 'not exist'
      redirect `/login`
    end
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
        settings.chat_rooms[session[:room_url]].room_members[session[:user_id]] = ws
      end
      ws.onmessage do |msg|
        settings.chat_rooms[session[:room_url]].room_members.each_value do |s|
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
