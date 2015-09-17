# == Schema Information
#
# Table name: menus
#
#  id             :integer          not null, primary key
#  title          :string(255)
#  online         :boolean          default(TRUE)
#  show_in_header :boolean          default(TRUE)
#  show_in_footer :boolean          default(FALSE)
#  ancestry       :string(255)
#  position       :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

#
# == Menu Model
#
class Menu < ActiveRecord::Base
  include Positionable

  translates :title, fallbacks_for_empty_translations: true
  active_admin_translates :title

  has_ancestry
  has_one :category, dependent: :nullify
  has_one :optional_module, through: :category

  delegate :name, to: :category, prefix: true, allow_nil: true
  delegate :optional, to: :category, prefix: true, allow_nil: true

  scope :only_parents, -> { where(ancestry: nil) }
  scope :with_page, -> { joins(:category).where.not('categories.menu_id': nil) }
  scope :visible_header, -> { where(show_in_header: true) }
  scope :visible_footer, -> { where(show_in_footer: true) }
  scope :online, -> { where(online: true) }
  scope :with_allowed_modules, -> { eager_load(:category, :optional_module).where('categories.optional=? OR (categories.optional=? AND optional_modules.enabled=?)', false, true, true) }

  def self.except_current_and_submenus(myself = nil)
    menus = []
    Menu.includes(:translations).only_parents.each do |menu|
      menus << menu if menu != myself
    end
    menus
  end

  def self.visible_header_title
    visible_header.collect { |c| [c.title, c.id] }
  end

  def self.self_or_available(myself = nil)
    menu = []
    Menu.includes(:translations, :category).each do |item|
      menu << item if item.category.nil? || item.try(:category) == myself
    end
    menu
  end

  # validates :ancestry,
  #           presence: false,
  #           allow_blank: true,
  #           inclusion: { in: except_current_and_submenus }
end