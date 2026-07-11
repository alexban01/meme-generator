require_relative 'spec_helper'
require_relative '../lib/database'

describe Database do
  subject(:database) { described_class.new(':memory:') }

  describe 'insert_user' do
    it 'saves the user into the database' do
      database.insert_user('user', 'password', '1234')

      user = database.find_user_by_username('user')
      expect(user['username']).to eq('user')
      expect(user['hashed_password']).to eq('password')
      expect(user['token']).to eq('1234')
    end

    it 'does not insert new user if the same username already exists' do
      database.insert_user('user', 'pass', '123')

      expect(database.insert_user('user', 'pass2', '1234')).to be(false)
    end
  end

  describe 'find_user' do
    it 'finds a user by username' do
      database.insert_user('user', 'pass', '1234')
      user = database.find_user_by_username('user')
      expect(user['username']).to eq('user')
    end

    it 'finds a user by token' do
      database.insert_user('user', 'pass', '1234')
      user = database.find_user_by_token('1234')
      expect(user['token']).to eq('1234')
    end
  end

  describe 'clear' do
    it 'clears the database' do
      database.insert_user('user', 'password', '1234')
      user = database.find_user_by_username('user')
      expect(user['username']).to eq('user')

      expect(database.clear).to be true
    end
  end
end
