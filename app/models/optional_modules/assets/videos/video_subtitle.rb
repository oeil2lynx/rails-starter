# == Schema Information
#
# Table name: video_subtitles
#
#  id                       :integer          not null, primary key
#  subtitleable_id          :integer
#  subtitleable_type        :string(255)
#  online                   :boolean          default(TRUE)
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  subtitle_fr_file_name    :string(255)
#  subtitle_fr_content_type :string(255)
#  subtitle_fr_file_size    :integer
#  subtitle_fr_updated_at   :datetime
#  subtitle_en_file_name    :string(255)
#  subtitle_en_content_type :string(255)
#  subtitle_en_file_size    :integer
#  subtitle_en_updated_at   :datetime
#
# Indexes
#
#  index_video_subtitles_on_subtitleable_type_and_subtitleable_id  (subtitleable_type,subtitleable_id)
#

#
# == VideoSubtitleModel
#
class VideoSubtitle < ActiveRecord::Base
  include Attachable

  belongs_to :subtitleable, polymorphic: true

  handle_attachment :subtitle_fr
  handle_attachment :subtitle_en

  do_not_validate_attachment_file_type :subtitle_fr
  do_not_validate_attachment_file_type :subtitle_en

  include DeletableAttachment

  scope :online, -> { where(online: true) }
end