class FaultNotificationMailer < ActionMailer::Base
  default from: SEND_NOTIFICATIONS_FROM

  def notify(user, fault, alarm, locomotive, account)
    @user = user
    @fault = fault
    @alarm = alarm
    @locomotive = locomotive
    @account = account

    mail to: @user.email, subject: @fault.title
  end
end
