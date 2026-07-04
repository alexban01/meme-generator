# frozen_string_literal: true

require_relative 'spec_helper'

describe 'POST /memes' do
  image_url = 'https://images.unsplash.com/photo-1647549831144-09d4c521c1f1'
  name = File.basename(URI.parse(image_url).path)
  path = "images/#{name}"
  fixture = File.binread('images/original.jpeg')

  before do
    stub_request(:get, image_url).to_return(body: fixture, status: 200)
  end

  def post_meme(url, text)
    post '/memes', { meme: { image_url: url, text: text } }.to_json, { 'CONTENT_TYPE' => 'application/json' }
  end

  it 'redirects 303 to the generated meme image' do
    post_meme(image_url, 'Hello World')

    expect(last_response.status).to eq(303)
    expect(last_response.location).to end_with("/memes/#{name}")
  end

  it 'returns 400 if link is empty' do
    post_meme('', 'Hello World')

    expect(last_response.status).to eq(400)
  end

  it 'returns 400 if text is empty' do
    post_meme(image_url, '')

    expect(last_response.status).to eq(400)
  end

  it 'returns 400 on malformed JSON' do
    post '/memes', 'test', { 'CONTENT_TYPE' => 'application/json' }

    expect(last_response.status).to eq(400)
  end

  it 'returns 413 if the image is larger than 25 MB' do
    data = 'a' * 26_214_401
    stub_request(:get, image_url).to_return(body: data, status: 200)
    post_meme(image_url, 'Hello World')
    expect(last_response.status).to eq(413)
  end

  after do
    File.delete(path) if File.exist?(path)
  end
end
