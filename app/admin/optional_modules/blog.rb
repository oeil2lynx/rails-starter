ActiveAdmin.register Blog do
  menu parent: I18n.t('admin_menu.modules')
  includes :translations

  permit_params :id,
                :type,
                :online,
                :user_id,
                translations_attributes: [
                  :id, :locale, :title, :slug, :content
                ],
                pictures_attributes: [
                  :id, :locale, :image, :online, :_destroy
                ],
                referencement_attributes: [
                  :id,
                  translations_attributes: [
                    :id, :locale, :title, :description, :keywords
                  ]
                ]

  decorate_with BlogDecorator
  config.clear_sidebar_sections!

  batch_action :toggle_value do |ids|
    Blog.find(ids).each do |blog|
      toggle_value = blog.online? ? false : true
      blog.update_attribute(:online, toggle_value)
    end
    redirect_to :back, notice: t('active_admin.batch_actions.flash')
  end

  index do
    selectable_column
    column :image
    column :title
    column :status
    translation_status
    column :author_with_avatar

    actions
  end

  show do
    render 'admin/posts/show', resource: resource
  end

  form do |f|
    render 'admin/posts/form', f: f
  end

  #
  # == Controller
  #
  controller do
    before_create do |blog|
      blog.user_id = current_user.id
    end
  end
end