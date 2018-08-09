class NewUserMailer < ActionMailer::Base
  default from: SEND_NOTIFICATIONS_FROM

  def notify_admin user, admin
    @new_user = user
    @admin = admin

    mail to: @admin.email, subject: "New User Created"
  end

  def notify_account_admin user, account_admin
    @new_user = user
    @account_admin = account_admin

    mail to: @account_admin.email, subject: "New User Created"
  end
end
