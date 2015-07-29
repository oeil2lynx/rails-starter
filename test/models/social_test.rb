require 'test_helper'

#
# == Social Model test
#
class SocialTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess

  setup :initialize_test

  test 'should count social network with share kind' do
    assert_equal 1, Social.share.count
  end

  test 'should count social network with follow kind' do
    assert_equal 2, Social.follow.count
  end

  test 'should return list of allowed title for social newtwork' do
    assert_includes Social.allowed_title_social_network, 'Facebook'
    assert_includes Social.allowed_title_social_network, 'Twitter'
    assert_includes Social.allowed_title_social_network, 'Google+'
    assert_includes Social.allowed_title_social_network, 'Email'
  end

  test 'should return list of allowed kind for social newtwork' do
    assert_includes Social.allowed_kind_social_network, 'follow'
    assert_includes Social.allowed_kind_social_network, 'share'
  end

  #
  # == Ikon
  #
  test 'should not upload ikon if mime type is not allowed' do
    [:original, :large, :medium, :small, :thumb].each do |size|
      assert_nil @social.ikon.path(size)
    end

    attachment = fixture_file_upload 'images/fake.txt', 'text/plain'
    @social.update_attributes(ikon: attachment)

    [:original, :large, :medium, :small, :thumb].each do |size|
      assert_not_processed 'fake.txt', size, @social.ikon
    end
  end

  test 'should upload ikon if mime type is allowed' do
    [:original, :large, :medium, :small, :thumb].each do |size|
      assert_nil @social.ikon.path(size)
    end

    attachment = fixture_file_upload 'images/social.png', 'image/png'
    @social.update_attributes!(ikon: attachment)

    [:original, :large, :medium, :small, :thumb].each do |size|
      assert_processed 'social.png', size, @social.ikon
    end
  end

  private

  def initialize_test
    @social = socials(:facebook_follow)
  end
end