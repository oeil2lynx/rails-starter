#
# == MailingMessage Mailer
#
class MailingMessageMailer < ApplicationMailer
  add_template_helper(HtmlHelper)
  default from: MailingSetting.first.decorate.email_status
  layout 'mailing'

  # Email MailingMessage
  def send_email(mailing_user, mailing_message)
    @mailing_user = mailing_user
    @mailing_message = mailing_message
    @title = @mailing_message.title
    @content = @mailing_message.content
    @show_in_email = true
    @hide_preview_link = false

    mail(to: @mailing_user.email, subject: @title) do |format|
      format.html
      format.text
    end
  end
end
