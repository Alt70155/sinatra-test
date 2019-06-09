require 'sinatra/reloader'
helpers do
  # 画像があるか・拡張子は正しいか・画像タグと画像数が同じかをチェック
  def article_img_valid?(body, img_files)
    return false if img_files.nil?
    body_img_ct = body.scan(/!\[\S*\]\(\S*\)/).length
    ary = img_files.map { |img| !(img[:filename] !~ /.*\.(jpg|png|jpeg)\z/) }
    body_img_ct == img_files.length && img_files.length < 10 && ary.all?
  end
end
