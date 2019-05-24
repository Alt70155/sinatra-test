require './app.rb'
require 'test/unit'
require 'rack/test'

ENV['APP_ENV'] = 'test'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_it_says_hello_world
    get '/'
    assert last_response.ok?
    assert equal 'Hello World', last_response.body
  end
end
