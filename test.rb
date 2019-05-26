require './app.rb'
require 'minitest/autorun'
require 'rack/test'

ENV['APP_ENV'] = 'test'

class AppTest < MiniTest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    @post = Post.new(cate_id: 1, title: "title", body: "body", top_picture: "picture.jpg")
  end

  def test_if_form_is_displayed_on_top_page
    get '/'
    assert last_response.ok?
    assert_match %r[<input class="title"],   last_response.body
    assert_match %r[<textarea class="body"], last_response.body
    assert_match %r[<input name="cate_id"],  last_response.body
    assert_match %r[<input accept="image/],  last_response.body
    assert_match %r[<input disabled="disabled" id="input_submit"], last_response.body
  end

  def test_valid_article_posting
    get '/'
    p post_ct = Post.count
    post '/article_post', params = {
      cate_id:     1,
      title:       "title",
      body:        "body",
      top_picture: "pic.jpg"
    }
    p post_ct_after = Post.count
    assert_equal post_ct + 1, post_ct_after
  end

  def test_to_check_the_length_of_the_title
    @post.title = ''
    assert !@post.valid? # falseを期待
    @post.title = 'a' * 80
    assert !@post.valid?
  end

  def test_to_check_the_length_of_the_body
    @post.body = ''
    assert !@post.valid? # falseを期待
    @post.body = 'a' * 20010
    assert !@post.valid?
  end

end
