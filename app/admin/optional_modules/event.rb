ActiveAdmin.register Event do
  menu parent: I18n.t('admin_menu.modules')

  permit_params :id,
                :url,
                :start_date,
                :end_date,
                :online,
                translations_attributes: [
                  :id, :locale, :title, :slug, :content
                ],
                pictures_attributes: [
                  :id, :image, :online, :_destroy
                ],
                referencement_attributes: [
                  :id,
                  translations_attributes: [
                    :id, :locale, :title, :description, :keywords
                  ]
                ]

  decorate_with EventDecorator
  config.clear_sidebar_sections!

  batch_action :toggle_value do |ids|
    Event.find(ids).each do |event|
      toggle_value = event.online? ? false : true
      event.update_attribute(:online, toggle_value)
    end
    redirect_to :back, notice: t('active_admin.batch_actions.flash')
  end

  index do
    selectable_column
    column :image
    column :title
    column :start_date
    column :end_date
    column :duration
    column :url
    column :status

    translation_status
    actions
  end

  show do
    columns do
      column do
        attributes_table do
          row :image
          row :content
          row :start_date
          row :end_date
          row :duration
          row :url
          row :status
        end
      end

      column do
        render 'admin/shared/referencement/show', referencement: resource.referencement
      end
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    columns do
      column do
        render 'admin/shared/form_translation', f: f
      end

      column do
        f.inputs t('activerecord.models.event.one') do
          f.input :start_date, as: :string,
                  input_html: {
                    class: 'datetimepicker',
                    value: f.object.start_date.blank? ? '' : f.object.start_date.localtime.to_s(:db)
                  },
                  hint: I18n.t('form.hint.start_date')

          f.input :end_date, as: :string,
                  input_html: {
                    class: 'datetimepicker',
                    value: f.object.end_date.blank? ? '' : f.object.end_date.localtime.to_s(:db)
                  },
                  hint: I18n.t('form.hint.end_date')

          f.input :url
          f.input :online
        end
      end
    end

    columns do
      column do
        render 'admin/shared/referencement/form', f: f
      end

      column do
        render 'admin/shared/pictures/many', f: f
      end
    end

    f.actions
  end

  controller do
    def update
      logger.debug "====== #{params[:event].inspect}"
      update!
    end
  end
end