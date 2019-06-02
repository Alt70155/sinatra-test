require 'sinatra'
require 'slim'
require 'sinatra/reloader'
require 'sinatra/activerecord'
require 'redcarpet'
require './helpers/markdown.rb'
require 'rack-flash'
enable :sessions
use Rack::Flash
# enable :sessions　これでダメな場合
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
  validates :top_picture, format: { with: /.*\.(jpg|png|jpeg)\z/,
                                    message: "is only jpg, jpeg, png" }
  # before_validation :file_check # save直前に実行される

  private
  # private
end

class Category < ActiveRecord::Base
end

get '/' do
  @category = Category.all
  slim :index
end

get '/articles/:id' do
  @post = Post.find(params[:id])
  @category = Category.where(cate_id: @post.cate_id)
  slim :articles
end

post '/article_post' do
  # 画像ファイル自体はモデルを持っていないため、存在チェックをコントローラで行う
  # params[:file]がnilの場合、params[:file][:filename]で例外が発生する
  # prevから投稿する場合、params[:pic_name]にファイル名を格納
  if params[:file] || params[:pic_name]
    !!params[:pic_name] ? pic_name = params[:pic_name] : pic_name = params[:file][:filename]
    @post = Post.new(
      cate_id:     params[:cate_id],
      title:       params[:title],
      body:        params[:body],
      top_picture: pic_name)

    if params[:back].nil? && @post.save
      # file作成
      File.open("public/img/#{@post.top_picture}", 'wb') { |f| f.write(params[:file][:tempfile].read) }

      flash[:notice] = "投稿完了"
      redirect "/articles/#{@post.id}"
    else
      File.delete("public/img/#{@post.top_picture}") if params[:back]
      @category = Category.all
      # エラーメッセージを表示させたいのでレンダーする
      slim :index
    end

  elsif params[:file_name].nil?

  else
    redirect '/'
  end
end

post '/article_prev' do
  unless params[:file].nil?
    @post = Post.new(
      id:          Post.count + 1, # ダミー
      cate_id:     params[:cate_id],
      title:       params[:title],
      body:        params[:body],
      top_picture: params[:file][:filename])

    # プレビューなので保存しないでvalid?だけチェックする
    # 画像は保存する
    if @post.valid?
      File.open("public/img/#{@post.top_picture}", 'wb') { |f| f.write(params[:file][:tempfile].read) }
      @category = Category.where(cate_id: @post.cate_id)
      slim :article_prev
    else
      # エラーメッセージを表示させたいのでレンダーする
      @category = Category.all
      slim :index
    end

  else
    redirect '/'
  end
end
