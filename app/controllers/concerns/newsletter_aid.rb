#
# == NewsletterConcern
#
module NewsletterAid
  extend ActiveSupport::Concern

  included do
    before_action :set_newsletter_user, only: [:unsubscribe, :see_in_browser, :welcome_user]
  end

  def set_newsletter_user
    @newsletter_user = NewsletterUser.find(params[:newsletter_user_id])
  rescue ActiveRecord::RecordNotFound
    flash[:error] = I18n.t('newsletter.unsubscribe.invalid')
    redirect_to :root
  end
end
