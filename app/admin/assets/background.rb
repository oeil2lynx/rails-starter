ActiveAdmin.register Background do
  menu parent: 'Assets'

  permit_params :id, :image, :attachable_id

  decorate_with BackgroundDecorator
  config.clear_sidebar_sections!

  index do
    selectable_column
    column :image_deco
    column :category_name
    actions
  end

  show title: :title_aa_show do
    attributes_table do
      row :category_name
      row :image_deco
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.inputs t('active_admin.details', model: active_admin_config.resource_label) do
      if current_user.super_administrator?
        f.input :attachable_id,
                as: :select,
                collection: Category.all.collect { |c| [c.title, c.id] },
                include_blank: false,
                input_html: { class: 'chosen-select' }
      end

      f.input :image,
              as: :file,
              label: I18n.t('form.label.background'),
              hint: retina_image_tag(f.object, :image, :medium)
    end

    f.actions
  end

  #
  # == Controller
  #
  controller do
    def edit
      @page_title = resource.decorate.title_aa_edit
    end

    def update
      params[:background].delete :attachable_id unless current_user.super_administrator?
      super
    end

    def destroy
      resource.image.clear
      resource.save
      super
    end
  end
end
