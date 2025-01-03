class ContactMailer < ApplicationMailer
  def contact_email
    @contact = params[:contact]
    mail(
      to: email_address_with_name(Rails.application.credentials.app_email, 'Morning Forest'),
      subject: "［お問い合わせ］ #{@contact.subject}"
    )
  end
end
