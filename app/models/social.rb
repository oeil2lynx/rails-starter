# == Schema Information
#
# Table name: socials
#
#  id                :integer          not null, primary key
#  title             :string(255)
#  link              :string(255)
#  kind              :string(255)
#  enabled           :boolean          default(TRUE)
#  ikon_updated_at   :datetime
#  ikon_file_size    :integer
#  ikon_content_type :string(255)
#  ikon_file_name    :string(255)
#  retina_dimensions :text(65535)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

#
# == Social Model
#
class Social < ActiveRecord::Base
  include Attachable

  def self.allowed_title_social_network
    %w( Facebook Twitter Google+ Email )
  end

  def self.allowed_kind_social_network
    %w( follow share )
  end

  retina!
  has_attachment :ikon,
                 styles: {
                   large: '128x128>',
                   medium: '64x64>',
                   small: '32x32>',
                   thumb: '16x16>'
                 }
  validates_attachment_content_type :ikon, content_type: %r{\Aimage\/.*\Z}

  include DeletableAttachment

  validates :title,
            presence: true,
            allow_blank: false,
            inclusion: { in: allowed_title_social_network }
  validates :kind,
            presence: true,
            allow_blank: true,
            inclusion: { in: allowed_kind_social_network }
  validates :link,
            presence: true, if: proc { |social| social.kind == 'follow' },
            url: true

  scope :follow, -> { where(kind: 'follow') }
  scope :share, -> { where(kind: 'share') }
  scope :enabled, -> { where(enabled: true) }
end