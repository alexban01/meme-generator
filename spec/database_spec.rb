require_relative 'spec_helper'
require_relative '../lib/database'

describe Database do
  subject(:database) { described_class.new(':memory:') }

  describe 'insert_user' do
    context 'when the user does not exist' do
      it 'saves the user into the database' do
        database.insert_user('user', 'password', '1234')

        user = database.find_user_by_username('user')
        expect(user['username']).to eq('user')
        expect(user['hashed_password']).to eq('password')
        expect(user['token']).to eq('1234')
      end

      it 'allows multiple users to be inserted' do
        database.insert_user('user1', 'pass', '1234')
        database.insert_user('user2', 'pass2', '1234')

        user1 = database.find_user_by_username('user1')
        expect(user1['username']).to eq('user1')

        user2 = database.find_user_by_username('user2')
        expect(user2['username']).to eq('user2')
      end
    end

    context 'when the user exists' do
      it 'does not insert new user if the same username already exists' do
        database.insert_user('user', 'pass', '123')

        expect(database.insert_user('user', 'pass2', '1234')).to be(false)
      end
    end
  end

  describe 'find_user' do
    context 'when the user exists' do
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

    context 'when the user does not exist' do
      it 'returns nil if the username is not found' do
        expect(database.find_user_by_username('no_user')).to be_nil
      end

      it 'returns nil if the token is not found' do
        expect(database.find_user_by_token('1234')).to be_nil
      end
    end
  end

  describe 'clear' do
    it 'clears the database' do
      database.insert_user('user', 'password', '1234')
      user = database.find_user_by_username('user')
      expect(user['username']).to eq('user')

      expect(database.clear).to be true
      expect(database.find_user_by_token('1234')).to be_nil
    end
  end
end
