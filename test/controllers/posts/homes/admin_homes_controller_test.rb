# frozen_string_literal: true
require 'test_helper'

#
# == Admin namespace
#
module Admin
  #
  # == HomesController test
  #
  class HomesControllerTest < ActionController::TestCase
    include Devise::Test::ControllerHelpers

    setup :initialize_test

    #
    # == Routes / Templates / Responses
    #
    test 'should get index page if logged in' do
      get :index
      assert_response :success
    end

    test 'should get show page if logged in' do
      get :show, params: { id: @home }
      assert_response :success
    end

    test 'should get edit page if logged in' do
      get :edit, params: { id: @home }
      assert_response :success
    end

    test 'should create if logged in' do
      assert_difference 'Home.count' do
        attrs = set_default_record_attrs
        post :create, params: { home: attrs }
        assert_equal 'Home', assigns(:home).type
        assert_equal @administrator.id, assigns(:home).user_id
        assert_redirected_to admin_home_path(assigns(:home))
      end
    end

    test 'should update home if logged in' do
      patch :update, params: { id: @home, home: {} }
      assert_redirected_to admin_home_path(@home)
    end

    test 'should destroy home' do
      assert_difference ['Home.count', 'Referencement.count'], -1 do
        delete :destroy, params: { id: @home }
        assert_redirected_to admin_homes_path
      end
    end

    #
    # == Batch actions
    #
    test 'should return correct value for toggle_online batch action' do
      post :batch_action, params: { batch_action: 'toggle_online', collection_selection: [@home.id] }
      [@home].each(&:reload)
      assert_not @home.online?
    end

    test 'should redirect to back and have correct flash notice for toggle_online batch action' do
      post :batch_action, params: { batch_action: 'toggle_online', collection_selection: [@home.id] }
      assert_redirected_to admin_homes_path
      assert_equal I18n.t('active_admin.batch_actions.flash'), flash[:notice]
    end

    test 'should redirect to back and have correct flash notice for reset_cache batch action' do
      post :batch_action, params: { batch_action: 'reset_cache', collection_selection: [@home.id] }
      assert_redirected_to admin_homes_path
      assert_equal I18n.t('active_admin.batch_actions.reset_cache'), flash[:notice]
    end

    #
    # == Maintenance
    #
    test 'should not render maintenance even if enabled and SA' do
      sign_in @super_administrator
      assert_no_maintenance_backend
    end

    test 'should not render maintenance even if enabled and Admin' do
      sign_in @administrator
      assert_no_maintenance_backend
    end

    test 'should render maintenance if enabled and subscriber' do
      sign_in @subscriber
      assert_maintenance_backend
      assert_redirected_to admin_dashboard_path
    end

    test 'should redirect to login if maintenance and not connected' do
      sign_out @administrator
      assert_maintenance_backend
      assert_redirected_to new_user_session_path
    end

    #
    # == Abilities
    #
    test 'should test abilities for subscriber' do
      sign_in @subscriber
      ability = Ability.new(@subscriber)
      assert ability.cannot?(:create, Home.new), 'should not be able to create'
      assert ability.cannot?(:read, @home), 'should not be able to read'
      assert ability.cannot?(:update, @home), 'should not be able to update'
      assert ability.cannot?(:destroy, @home), 'should not be able to destroy'

      assert ability.cannot?(:toggle_online, @home), 'should not be able to toggle_online'
      assert ability.cannot?(:reset_cache, @home), 'should not be able to reset_cache'
    end

    test 'should test abilities for administrator' do
      ability = Ability.new(@administrator)
      assert ability.can?(:create, Blog.new), 'should be able to create'
      assert ability.can?(:read, @home), 'should be able to read'
      assert ability.can?(:update, @home), 'should be able to update'
      assert ability.can?(:destroy, @home), 'should be able to destroy'

      assert ability.can?(:toggle_online, @home), 'should be able to toggle_online'
      assert ability.can?(:reset_cache, @home), 'should be able to reset_cache'
    end

    test 'should test abilities for super_administrator' do
      sign_in @super_administrator
      ability = Ability.new(@super_administrator)
      assert ability.can?(:create, Blog.new), 'should be able to create'
      assert ability.can?(:read, @home), 'should be able to read'
      assert ability.can?(:update, @home), 'should be able to update'
      assert ability.can?(:destroy, @home), 'should be able to destroy'

      assert ability.can?(:toggle_online, @home), 'should be able to toggle_online'
      assert ability.can?(:reset_cache, @home), 'should be able to reset_cache'
    end

    #
    # == Crud actions
    #
    test 'should redirect to users/sign_in if not logged in' do
      sign_out @administrator
      assert_crud_actions(@home, new_user_session_path, model_name)
    end

    test 'should redirect to dashboard if subscriber' do
      sign_in @subscriber
      assert_crud_actions(@home, admin_dashboard_path, model_name)
    end

    private

    def initialize_test
      @setting = settings(:one)
      @request.env['HTTP_REFERER'] = admin_homes_path

      @home = posts(:home)

      @subscriber = users(:alice)
      @administrator = users(:bob)
      @super_administrator = users(:anthony)
      sign_in @administrator
    end
  end
end
