# frozen_string_literal: true

require_relative 'spec_helper'

def signup(username, password)
  post '/signup', { user: { username: username, password: password } }.to_json,
       { 'CONTENT_TYPE' => 'application/json' }
end

def login(username, password)
  post '/login', { user: { username: username, password: password } }.to_json,
       { 'CONTENT_TYPE' => 'application/json' }
end

describe 'POST /signup' do
  after { File.delete('test_users.json') if File.exist?('test_users.json') }

  it 'creates a user and returns a token' do
    signup('user', 'password')

    expect(last_response.status).to eq(201)
    expect(JSON.parse(last_response.body)['user']['token']).not_to be_empty
  end

  it 'returns 400 if username is blank' do
    signup('', 'password')

    expect(last_response.status).to eq(400)
    expect(last_response.body).to include('Username is blank')
  end

  it 'returns 400 if password is blank' do
    signup('user', '')

    expect(last_response.status).to eq(400)
    expect(last_response.body).to include('Password is blank')
  end

  it 'returns 409 if the username already exists' do
    signup('user', 'password')
    signup('user', 'other')

    expect(last_response.status).to eq(409)
  end
end

describe 'POST /login' do
  after { File.delete('test_users.json') if File.exist?('test_users.json') }

  it 'returns the token when credentials are correct' do
    signup('user', 'password')
    login('user', 'password')

    expect(last_response.status).to eq(200)
    expect(JSON.parse(last_response.body)['user']['token']).not_to be_empty
  end

  it 'returns 401 when the password is wrong' do
    signup('user', 'password')
    login('user', 'wrong')

    expect(last_response.status).to eq(401)
  end

  it 'returns 401 when the user does not exist' do
    login('nobody', 'password')

    expect(last_response.status).to eq(401)
  end
end
