# frozen_string_literal: true

require 'sinatra'
require 'mini_magick'
require 'open-uri'
require 'json'
require 'digest'
require 'bcrypt'
require 'securerandom'

USERS_FILE = ENV.fetch('USERS_FILE', 'users.json')

def load_users
  File.exist?(USERS_FILE) ? JSON.parse(File.read(USERS_FILE)) : {}
end

def save_users(users)
  File.write(USERS_FILE, JSON.generate(users))
end

post '/signup' do
  user = JSON.parse(request.body.read)['user']
  return [400, { errors: [{ message: 'Username is blank' }] }.to_json] if user['username'].to_s.empty?
  return [400, { errors: [{ message: 'Password is blank' }] }.to_json] if user['password'].to_s.empty?

  users = load_users
  return 409 if users.key?(user['username'])

  token = SecureRandom.hex(16)
  users[user['username']] = { 'password' => BCrypt::Password.create(user['password']).to_s, 'token' => token }
  save_users(users)

  [201, { user: { token: token } }.to_json]
end

post '/login' do
  creds = JSON.parse(request.body.read)['user']
  user = load_users[creds['username'].to_s]
  return 401 unless user && BCrypt::Password.new(user['password']) == creds['password']

  [200, { user: { token: user['token'] } }.to_json]
end

before '/memes' do
  token = request.env['HTTP_AUTHORIZATION'].to_s.sub('Bearer ', '')
  halt 401 unless load_users.values.any? { |u| u['token'] == token }
end

get '/redirect' do
  redirect '/memes/meme2.jpg', 307
end

post '/memes' do
  begin
    meme = JSON.parse(request.body.read)['meme']
  rescue JSON::ParserError
    return 400
  end

  return 400 if meme['image_url'] == ''

  return 400 if meme['text'] == ''

  uri = URI.parse(meme['image_url'])

  # TODO: download meta-data first then decide if its too big
  data = uri.open.read
  return 413 if data.bytesize >= 26_214_400

  extension = File.extname(uri.path)
  filename = "#{Digest::SHA256.hexdigest(data)}#{extension}"
  path = "images/#{filename}"

  File.open(path, 'wb') { |f| f.write(data) }

  image = MiniMagick::Image.new(path)
  image.combine_options do |c|
    c.gravity 'center'
    c.draw "text 0,200 '#{meme['text']}'"
    c.undercolor 'White'
    c.fill 'Black'
    c.pointsize '60'
  end
  image.write(path)

  redirect "/memes/#{filename}", 303
end

# This is just for demo purposes
#  you should not use unsanitized parameters provided by user to access file paths
get '/memes/:file' do
  path = "#{File.dirname(__FILE__)}/images/#{params[:file]}"
  send_file(path)
end
