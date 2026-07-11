# frozen_string_literal: true

require_relative 'spec_helper'
require 'pry'

describe 'POST /signup' do
  subject(:signup) { post '/signup', body, { 'CONTENT_TYPE' => 'application/json' } }

  let(:body) { { user: { username: username, password: password } }.to_json }
  let(:username) { 'username' }
  let(:password) { 'password' }

  it 'creates a user and returns a token' do
    signup
    # binding.pry
    expect(last_response.status).to eq(201)
    expect(JSON.parse(last_response.body)['user']['token']).not_to be_empty
  end

  context 'when username is blank' do
    let(:username) { '' }

    it 'returns 400' do
      signup

      expect(last_response.status).to eq(400)
      expect(last_response.body).to include('Username is blank')
    end
  end

  context 'when password is blank' do
    let(:password) { '' }

    it 'returns 400' do
      signup

      expect(last_response.status).to eq(400)
      expect(last_response.body).to include('Password is blank')
    end
  end

  context 'when username is already taken' do
    before { post '/signup', body, { 'CONTENT_TYPE' => 'application/json' } }

    it 'returns 409' do
      signup

      expect(last_response.status).to eq(409)
    end
  end
end

describe 'POST /login' do
  subject(:login) { post '/login', body, { 'CONTENT_TYPE' => 'application/json' } }

  let(:body) { { user: { username: username, password: password } }.to_json }
  let(:username) { 'username' }
  let(:password) { 'password' }

  before do
    db = Database.new(ENV.fetch('DB_PATH', 'data/users.db'))
    db.insert_user('username', BCrypt::Password.create(password, {}).to_s, '1234')
  end

  context 'when credentials are correct' do
    it 'returns the token' do
      login
      binding.pry
      expect(last_response.status).to eq(200)
      expect(JSON.parse(last_response.body)['user']['token']).not_to be_empty
    end
  end

  context 'when credentials are incorrect' do
    it 'returns 403' do
      login

      expect(last_response.status).to eq(403)
    end
  end

  context 'when the user does not exist' do
    let(:username) { 'doesntExist' }
    it 'returns 403' do
      login

      expect(last_response.status).to eq(403)
    end
  end
end
