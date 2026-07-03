require_relative 'spec_helper'

describe 'POST /memes' do
  image_url = 'https://images.unsplash.com/photo-1647549831144-09d4c521c1f1'
  name = File.basename(URI.parse(image_url).path)
  path = "images/#{name}"
  fixture = File.binread('images/original.jpeg')

  before do
    stub_request(:get, image_url).to_return(body: fixture, status: 200)
  end

  it 'redirects (303) to the generated meme image' do
    post '/memes', { meme: { image_url: image_url, text: 'Hello' } }.to_json, { 'CONTENT_TYPE' => 'application/json' }

    expect(last_response.status).to eq(303)
    expect(last_response.location).to end_with("/memes/#{name}")
  end

  after do
    File.delete(path) if File.exist?(path)
  end
end
