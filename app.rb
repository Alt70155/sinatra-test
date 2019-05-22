require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'active_record'
require 'redcarpet'
require './helpers/markdown.rb'
# enable :sessions　これだとダメらしい
use Rack::Session::Cookie

# database.ymlを読み込み
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# developmentを設定
ActiveRecord::Base.establish_connection(:development)

class Post < ActiveRecord::Base
end

class Category < ActiveRecord::Base
end

get '/' do
  @category = Category.all
  slim :index
end

get '/articles/:id' do
  @post = Post.find(params[:id])
  @post_body_html = markdown(@post.body)
  @category = Category.where(cate_id: @post.cate_id)
  slim :articles
end

post '/article_post' do
  post_data = Post.create(
    title:       params[:title],
    body:        params[:body],
    cate_id:     params[:cate_id],
    top_picture: params[:file][:filename]
  )
  # file受け取り
  file = params[:file][:tempfile]
  # file作成
  File.open("public/img/#{post_data.top_picture}", 'wb') do |f|
    f.write(file.read)
  end

  redirect "/articles/#{post_data.id}"
end
