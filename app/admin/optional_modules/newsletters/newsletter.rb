ActiveAdmin.register Newsletter do
  menu parent: I18n.t('admin_menu.modules')

  permit_params :id,
                :sent_at,
                translations_attributes: [
                  :id, :locale, :title, :content
                ]

  decorate_with NewsletterDecorator
  config.clear_sidebar_sections!

  index do
    selectable_column
    column :title
    column :preview
    column :status
    column :sent_at
    column :send_link

    translation_status
    actions
  end

  show do
    panel t('active_admin.details', model: active_admin_config.resource_label) do
      attributes_table_for resource.decorate do
        row :status
        row :sent_at
        row :preview
        row :live_preview
        row :send_link
      end
    end
  end

  form partial: 'form'

  #
  # == Controller
  #
  controller do
    include NewsletterHelper

    before_action :set_newsletter,
                  only: [
                    :show, :edit, :update, :destroy,
                    :send_newsletter, :send_newsletter_test
                  ]
    before_action :set_variables, only: [:preview]

    def send_newsletter
      @newsletter.update_attributes(sent_at: Time.zone.now)
      @newsletter_users = NewsletterUser.find_each
      make_newsletter_with_i18n(@newsletter, @newsletter_users)

      count = @newsletter_users.count
      flash[:notice] = "La newsletter est en train d'être envoyée à #{count} personnes"
      make_redirect
    end

    def send_newsletter_test
      @newsletter_testers = NewsletterUser.testers
      make_newsletter_with_i18n(@newsletter, @newsletter_testers)

      newsletter_testers = @newsletter_testers.map(&:email).join(', ')
      flash[:notice] = "La newsletter est en train d'être envoyée à #{newsletter_testers}"
      make_redirect
    end

    def preview
      I18n.with_locale(params[:locale]) do
        @newsletter = Newsletter.find(params[:id])
        @title = @newsletter.title
      end
      @preview_newsletter = true
      render layout: 'newsletter'
    end

    private

    def make_newsletter_with_i18n(newsletter, newsletter_users)
      I18n.available_locales.each do |locale|
        I18n.with_locale(locale) do
          newsletter_users.each do |user|
            if user.lang == locale.to_s
              NewsletterJob.set(wait: 3.seconds).perform_later(user, newsletter)
            end
          end
        end
      end
    end

    def set_newsletter
      @newsletter = Newsletter.find(params[:id])
    end

    def make_redirect
      redirect_to :back
    end

    def set_variables
      @host = Figaro.env.application_host
      @preview_newsletter = true
    end
  end
end