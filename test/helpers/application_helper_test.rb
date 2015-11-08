require 'test_helper'

#
# == ApplicationHelper Test
#
class ApplicationHelperTest < ActionView::TestCase
  include Rails.application.routes.url_helpers

  setup :initialize_test

  test 'should return current year' do
    assert_equal current_year, Time.zone.now.year
  end

  test 'should return true if maintenance is enabled' do
    @setting.update_attributes(maintenance: true)
    assert maintenance?(@request), 'should be in maintenance'
  end

  test 'should return false if maintenance is disabled' do
    assert_not maintenance?(@request), 'should not be in maintenance'
  end

  private

  def initialize_test
    @setting = settings(:one)
  end
end
