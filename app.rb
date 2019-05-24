require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'redcarpet'
require './helpers/markdown.rb'
# enable :sessions　これだとダメらしい
# use Rack::Session::Cookie
# クッキー内のセッションデータはセッション秘密鍵(session secret)で署名されます。
# Sinatraによりランダムな秘密鍵が個別に生成されるらしい
# 個別で設定する場合は↓
# set :session_secret, 'super secret'

# database.ymlを読み込み
ActiveRecord::Base.configurations = YAML.load_file('database.yml')
# developmentを設定
ActiveRecord::Base.establish_connection(:development)

class Post < ActiveRecord::Base
  validates_presence_of :title, :body, :top_picture # 値が空じゃないか
  validates :title, length: { in: 1..75 }
  validates :body,  length: { in: 1..20000 }
  before_validation :file_valid # save直前に実行される

  private

    def file_valid

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
  unless params[:file].nil?
    post_data = Post.new(
      cate_id:     params[:cate_id],
      title:       params[:title],
      body:        params[:body],
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

end

get '/articles/:id' do
  @post = Post.find(params[:id])
  @category = Category.where(cate_id: @post.cate_id)
  slim :articles
end
