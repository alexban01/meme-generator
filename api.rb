require 'sinatra'
require 'mini_magick'
require 'open-uri'
require 'json'

get "/redirect" do
  redirect "/memes/meme2.jpg", 307
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

  filename = File.basename(uri.path)
  path = "images/#{filename}"

  data = uri.open.read
  return 413 if data.bytesize >= 26214400

  File.open(path, 'wb') { |f| f.write(data) }

  image = MiniMagick::Image.new(path)
  image.combine_options do |c|
    c.gravity "center"
    c.draw "text 0,200 '#{meme['text']}'"
    c.undercolor "White"
    c.fill "Black"
    c.pointsize "60"
  end
  image.write(path)

  redirect "/memes/#{filename}", 303
end

# This is just for demo purposes
#  you should not use unsanitized parameters provided by user to access file paths
get '/memes/:file' do
  path = File.dirname(__FILE__) + '/images/' + params[:file]
  send_file(path)
end