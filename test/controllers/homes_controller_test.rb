require 'test_helper'

class HomesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  setup :initialize_test

  test 'should get index' do
    I18n.available_locales.each do |locale|
      get :index, locale: locale.to_s
      assert_response :success
      assert_not_nil @home
    end
  end

  test 'should use index template' do
    I18n.available_locales.each do |locale|
      get :index, locale: locale.to_s
      assert_template :index
    end
  end

  test 'should get hompepage targetting home controller' do
    assert_routing '/', controller: 'home', action: 'index', locale: 'fr'
    assert_routing '/en', controller: 'home', action: 'index', locale: 'en'
  end

  private

  def initialize_tests
    @home = homes(:one)
  end
end
