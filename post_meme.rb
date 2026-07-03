require 'net/http'
require 'json'
require 'uri'

data = {
  meme: {
    image_url: 'https://images.unsplash.com/photo-1647549831144-09d4c521c1f1',
    text: 'Start the way by organising your playground'
  }
}.to_json

response = Net::HTTP.post(URI('http://localhost:4567/memes'), data, 'Content-Type' => 'application/json')
meme = Net::HTTP.get_response(URI(response['Location']))
File.write('images/meme_result.jpg', meme.body)
