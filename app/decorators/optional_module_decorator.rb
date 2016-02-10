#
# == OptionalModuleDecorator
#
class OptionalModuleDecorator < ApplicationDecorator
  include Draper::LazyHelpers
  delegate_all

  #
  # Content
  #
  def name_deco
    content_tag :strong, translated_module_name
  end

  #
  # == ActiveAdmin
  #
  def title_aa_show
    translated_module_name
  end

  #
  # == Status tag
  #
  def status
    color = model.enabled? ? 'green' : 'red'
    status_tag_deco(I18n.t("enabled.#{model.enabled}"), color)
  end

  private

  def translated_module_name
    t("optional_module.name.#{model.name.underscore.downcase}")
  end
end
