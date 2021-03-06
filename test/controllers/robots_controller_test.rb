# frozen_string_literal: true
require 'test_helper'

#
# == RobotsController Test
#
class RobotsControllerTest < ActionController::TestCase
  test 'should get index' do
    get :index, params: { format: :txt }
    assert_response :success
  end

  test 'should get allow template if Rails env is production' do
    Rails.env = 'production'
    get :index, params: { format: :txt }
    assert_template :allow
  end

  test 'should get disallow template if Rails env is development' do
    Rails.env = 'development'
    get :index, params: { format: :txt }
    assert_template :disallow
  end

  test 'should get disallow template if Rails env is staging' do
    Rails.env = 'staging'
    get :index, params: { format: :txt }
    assert_template :disallow
  end
end
