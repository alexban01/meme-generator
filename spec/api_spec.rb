# frozen_string_literal: true

require_relative 'spec_helper'
require 'digest'

describe 'POST /memes' do
  image_url = 'https://images.unsplash.com/photo-1647549831144-09d4c521c1f1'
  fixture = File.binread('images/original.jpeg')
  name = "#{Digest::SHA256.hexdigest(fixture)}#{File.extname(URI.parse(image_url).path)}"
  path = "images/#{name}"

  token = nil

  before do
    stub_request(:get, image_url).to_return(body: fixture, status: 200)
    post '/signup', { user: { username: 'user', password: 'password' } }.to_json,
         { 'CONTENT_TYPE' => 'application/json' }
    token = JSON.parse(last_response.body)['user']['token']
  end

  after do
    File.delete(path) if File.exist?(path)
  end

  def post_meme(url, text, token)
    post '/memes', { meme: { image_url: url, text: text } }.to_json,
         { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{token}" }
  end

  context 'when the image is generated successfully' do
    it 'redirects 303' do
      post_meme(image_url, 'Hello World', token)

      expect(last_response.status).to eq(303)
      expect(last_response.location).to end_with("/memes/#{name}")
    end
  end

  context 'when an invalid token is used' do
    it 'returns 401' do
      post_meme(image_url, 'Hello World', 'bad-token')

      expect(last_response.status).to eq(401)
    end
  end

  context 'when the inputs are empty' do
    it 'returns 400 for no url' do
      post_meme('', 'Hello World', token)

      expect(last_response.status).to eq(400)
    end

    it 'returns 400 for no text' do
      post_meme(image_url, '', token)

      expect(last_response.status).to eq(400)
    end
  end

  context 'when JSON is malformed' do
    it 'returns 400' do
      post '/memes', 'test', { 'CONTENT_TYPE' => 'application/json', 'HTTP_AUTHORIZATION' => "Bearer #{token}" }

      expect(last_response.status).to eq(400)
    end
  end

  context 'when the image is too large' do
    it 'returns 413' do
      data = 'a' * 26_214_401
      stub_request(:get, image_url).to_return(body: data, status: 200)
      post_meme(image_url, 'Hello World', token)
      expect(last_response.status).to eq(413)
    end
  end
end
