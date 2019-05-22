require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'redcarpet'
require './helpers/markdown.rb'
# enable :sessions　これだとダメらしい
use Rack::Session::Cookie

# database.ymlを読み込み
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# developmentを設定
ActiveRecord::Base.establish_connection(:development)

class Post < ActiveRecord::Base
  # validates_presence_of :title
  before_validation :test # save直前に実行される

  private

    def test
      p 'ok'
    end

  private
end

class Category < ActiveRecord::Base
end

get '/' do
  @category = Category.all
  slim :index
end

post '/article_post' do
  post_data = Post.new(
    title:       params[:title],
    body:        params[:body],
    cate_id:     params[:cate_id],
    top_picture: params[:file][:filename]
  )
  if post_data.save
    # file受け取り
    file = params[:file][:tempfile]
    # file作成
    File.open("public/img/#{post_data.top_picture}", 'wb') do |f|
      f.write(file.read)
    end
    redirect "/articles/#{post_data.id}"
  else
    redirect '/'
  end
end

get '/articles/:id' do
  @post = Post.find(params[:id])
  @category = Category.where(cate_id: @post.cate_id)
  slim :articles
end
