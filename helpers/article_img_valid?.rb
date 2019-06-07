helpers do
  def article_img_valid?(body, article_img_files)
    body_img_ct = body.scan(/!\[\S*\]\(\S*\)/).length
    ary = article_img_files.map { |img| !(img[:filename] !~ /.*\.(jpg|png|jpeg)\z/) }
    body_img_ct == article_img_files.length && ary.all?
  end
end
