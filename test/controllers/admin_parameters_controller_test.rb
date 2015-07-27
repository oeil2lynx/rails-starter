require 'test_helper'

#
# == Admin namespace
#
module Admin
  #
  # == ParametersController test
  #
  class ParametersControllerTest < ActionController::TestCase
    include Devise::TestHelpers

    setup :initialize_test

    test 'should redirect to users/sign_in if not logged in' do
      sign_out @administrator
      assert_crud_actions(@setting, new_user_session_path)
    end

    test 'should redirect index to show if logged in' do
      get :index
      assert_redirected_to admin_parameter_path(@setting)
    end

    test 'should show show page if logged in' do
      get :show, id: @setting
      assert_response :success
    end

    test 'should show edit page if logged in' do
      get :edit, id: @setting
      assert_response :success
    end

    test 'should update setting if logged in' do
      patch :update, id: @setting, setting: {}
      assert_redirected_to admin_parameter_path(@setting)
    end

    #
    # == Form validations
    #
    test 'should not update article without name' do
      patch :update, id: @setting
      assert_not @setting.update(name: nil)
    end

    test 'should not update article without title' do
      patch :update, id: @setting
      assert_not @setting.update(title: nil)
    end

    #
    # == Logo
    #
    test 'should be able to upload logo' do
      upload_paperclip_attachment
      setting = assigns(:parameter)
      assert setting.logo?, 'a logo should have been uploaded'
      assert_equal 'bart.png', setting.logo_file_name
      assert_equal 'image/png', setting.logo_content_type
    end

    # # TODO: Fix this broken test
    # test 'should be able to destroy logo' do
    #   upload_paperclip_attachment
    #   remove_paperclip_attachment
    #   assert_nil assigns(:setting).logo_file_name
    #   assert_not assigns(:setting).logo?
    # end

    #
    # == Abilities
    #
    test 'should test abilities for subscriber' do
      sign_in @subscriber
      ability = Ability.new(@subscriber)
      assert ability.cannot?(:create, Setting.new), 'should not be able to create'
      assert ability.cannot?(:read, Setting.new), 'should not be able to read'
      assert ability.cannot?(:update, Setting.new), 'should not be able to update'
      assert ability.cannot?(:destroy, Setting.new), 'should not be able to destroy'
    end

    test 'should test abilities for administrator' do
      ability = Ability.new(@administrator)
      assert ability.cannot?(:create, Setting.new), 'should not be able to create'
      assert ability.can?(:read, Setting.new), 'should be able to read'
      assert ability.can?(:update, Setting.new), 'should be able to update'
      assert ability.cannot?(:destroy, Setting.new), 'should not be able to destroy'
    end

    test 'should test abilities for super_administrator' do
      sign_in @super_administrator
      ability = Ability.new(@super_administrator)
      assert ability.can?(:create, Setting.new), 'should be able to create'
      assert ability.can?(:read, Setting.new), 'should be able to read'
      assert ability.can?(:update, Setting.new), 'should be able to update'
      assert ability.can?(:destroy, Setting.new), 'should be able to destroy'
    end

    #
    # == Subscriber
    #
    test 'should redirect to dashboard page if trying to access setting as subscriber' do
      sign_in @subscriber
      assert_crud_actions(@setting, admin_dashboard_path)
    end

    private

    def initialize_test
      @setting = settings(:one)

      @subscriber = users(:alice)
      @administrator = users(:bob)
      @super_administrator = users(:anthony)
      sign_in @administrator
    end

    def upload_paperclip_attachment
      puts '=== Uploading logo'
      attachment = fixture_file_upload 'images/bart.png', 'image/png'
      patch :update, id: @setting, setting: { logo: attachment }
    end

    def remove_paperclip_attachment
      puts '=== Removing logo'
      patch :update, id: assigns(:setting), setting: { logo: nil, delete_logo: '1' }
    end

    def assert_crud_actions(obj, url)
      get :index
      assert_redirected_to url
      get :edit, id: obj
      assert_redirected_to url
      post :create, setting: {}
      assert_redirected_to url
      patch :update, id: obj, setting: {}
      assert_redirected_to url
    end
  end
end