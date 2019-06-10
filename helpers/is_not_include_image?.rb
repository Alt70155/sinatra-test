require 'sinatra/reloader'
helpers do
  def is_not_include_image?(body, img_files)
    img_tag_ct = body.scan(/!\[\S*\]\(\S*\)/).length
    # 画像タグも画像もない場合
    if img_tag_ct == 0 && img_files.nil?
      return true
    # 画像タグがあって画像がない場合
    elsif img_tag_ct > 0 && img_files.nil?
      return false
    else
      # その他バリデーション
      img_valid?(img_tag_ct, img_files)
    end
  end

  # 拡張子は正しいか・画像タグと画像数が同じかをチェック
  def img_valid?(img_tag_ct, img_files)
    ary = img_files.map { |img| !(img[:filename] !~ /.*\.(jpg|png|jpeg)\z/) }
    body_img_ct == img_files.length && img_files.length < 10 && ary.all?
  end
end
