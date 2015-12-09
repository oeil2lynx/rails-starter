require 'test_helper'

#
# == MailingUsersController Test
#
class MailingUsersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  include Rails.application.routes.url_helpers

  setup :initialize_test

  #
  # == Unsubscribing
  #
  test 'should render success unsubscribe template' do
    delete :unsubscribe, locale: 'fr', id: @mailing_user.id, token: @mailing_user.token
    assert_template :success_unsubscribe
  end

  test 'should unsubscribe newsletter user if token is correct' do
    assert_difference ['MailingUser.count'], -1 do
      delete :unsubscribe, locale: 'fr', id: @mailing_user.id, token: @mailing_user.token
    end
  end

  test 'should not unsubscribe newsletter user if token is wrong' do
    assert_no_difference ['MailingUser.count'] do
      assert_raises(ActionController::RoutingError) do
        delete :unsubscribe, locale: 'fr', id: @mailing_user.id, token: "#{@mailing_user.token}-abc"
      end
    end
  end

  private

  def initialize_test
    @locales = I18n.available_locales
    @mailing_user = mailing_users(:one)
    @setting = settings(:one)
  end
end
