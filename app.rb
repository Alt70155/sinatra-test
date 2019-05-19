require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'active_record'

# database.ymlを読み込んでくれえ
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# development設定でお願い
ActiveRecord::Base.establish_connection(:development)

class Post < ActiveRecord::Base
   # 値が空でないか
   validates_presence_of :title
   validates_presence_of :body
end

class Category < ActiveRecord::Base
end

get '/' do
  @category = Category.all
  slim :index
end

get '/articles/:id' do
  @post = Post.find(params[:id])
  @category = Category.where(cate_id: 1)
  slim :articles
end

post '/article_post' do
  post_data = Post.create(
    title: params[:title],
    body:  params[:body],
    cate_id: params[:cate_id]
  )
  redirect "/articles/#{post_data.id}"
end
