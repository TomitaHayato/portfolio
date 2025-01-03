class ContactsController < ApplicationController
  skip_before_action :require_login

  def show; end

  def new
    @contact        = Contact.new
    @subjects_array = Contact.subjects.keys
    @user           = current_user&.general? ? current_user : nil
  end

  def create
    @contact = Contact.new(contact_params)
    if @contact.save
      ContactMailer.with(contact: @contact).contact_email.deliver_later
      redirect_to contact_path(@contact)
    else
      @subjects_array = Contact.subjects.keys
      @user           = current_user&.general? ? current_user : nil
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contact_params
    params.require(:contact).permit(:name, :email, :subject, :message, :is_need_response)
  end
end
