# frozen_string_literal: true

require 'sqlite3'

class Database
  def initialize(path = 'data/users.db')
    @db = SQLite3::Database.new(path)
    @db.results_as_hash = true
    create_tables
  end

  def create_tables
    @db.execute <<-SQL
      create table if not exists users (
        id integer primary key,
        username text unique,
        hashed_password text,
        token text
      )
    SQL
  end

  def insert_user(username, hashed_password, token)
    @db.execute(
      'insert into users (username, hashed_password, token) values (?, ?, ?)',
      [username, hashed_password, token]
    )
    true
  rescue SQLite3::Exception
    false
  end

  def find_user_by_username(username)
    @db.execute('select * from users where username = ?', [username]).first
  end

  def find_user_by_token(token)
    @db.execute('select * from users where token = ?', [token]).first
  end

  def clear
    @db.execute('delete from users')
    true
  rescue SQLite3::Exception
    false
  end
end
