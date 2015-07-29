ActiveAdmin.register Social do
  menu parent: I18n.t('admin_menu.modules')

  permit_params :id,
                :title,
                :link,
                :kind,
                :enabled,
                :ikon,
                :delete_ikon

  decorate_with SocialDecorator
  config.clear_sidebar_sections!

  batch_action :toggle_value do |ids|
    Social.find(ids).each do |guest_book|
      toggle_value = guest_book.enabled? ? false : true
      guest_book.update_attribute(:enabled, toggle_value)
    end
    redirect_to :back, notice: t('active_admin.batch_actions.flash')
  end

  index do
    selectable_column
    column :ikon_deco
    column :title
    column :kind
    column :link
    column :status

    actions
  end

  show do
    attributes_table do
      row :ikon_deco
      row :title
      row :kind
      row :link unless resource.kind == 'share'
      row :status
    end
  end

  form do |f|
    f.semantic_errors(*f.object.errors.keys)

    f.columns do
      f.column do
        f.inputs 'Paramètres du Réseau Social' do
          f.input :title,
                  collection: Social.allowed_title_social_network,
                  include_blank: false,
                  hint: 'Titre du réseau social',
                  input_html: {
                    class: 'chosen-select',
                    disabled: current_user.super_administrator? ? false : :disbaled
                  }

          f.input :kind,
                  collection: Social.allowed_kind_social_network,
                  input_html: {
                    class: 'chosen-select',
                    disabled: current_user.super_administrator? ? false : :disbaled
                  }

          if f.object.kind != 'share'
            f.input :link, hint: 'Lien du réseau social'
          end
          f.input :enabled, hint: 'Activer ce réseau social ?'
        end
      end

      f.column do
        f.inputs 'Icône du Réseau Social' do
          f.input :ikon, hint: f.object.decorate.ikon_deco
          if f.object.decorate.ikon?
            f.input :delete_ikon,
                    as: :boolean,
                    hint: 'Si coché, l\'icône du réseau social sera supprimée après mise à jour de l\'élément'
          end
        end
      end
    end

    f.actions
  end

  #
  # == Controller
  #
  controller do
    def update
      if !current_user.super_administrator? && params[:social]
        params[:social].delete :title
        params[:social].delete :kind
      end

      super
    end
  end
end