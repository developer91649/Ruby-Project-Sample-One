class InvitationLink
  def self.for user, linker
    linker.link_to(
      "Send Invitation",
      linker.invite_admin_user_path(user),
      method: :post)
  end
end

ActiveAdmin.register User do

  controller do
    after_filter :notify_account_admins, only: :create

    after_filter :invite_created_user, only: :create

    before_filter :get_initial_approval_status, only: :update
    after_filter :invite_updated_user, only: :update

    def notify_account_admins
      @user.notify_account_admins if @user.valid?
    end

    def invite_created_user
      @user.invite_if_approved
    end

    def invite_updated_user
      @user.invite_if_approval_changed(@initial_approval_status)
    end

    def get_initial_approval_status
      @initial_approval_status = User.find(params[:id]).fully_approved?
    end
  end

  filter :account
  filter :email

  form do |f|
    f.inputs(user.email) do
      if(user.new_record?)
        f.input :account
        f.input :email
      else
        f.input :email, input_html: { disabled: true }
      end
      if current_user.admin? or current_user.mpi_admin?
        f.input :approved_by_admin, input_html: { checked: user.new_record? ? true : user.approved_by_admin }
        f.input :approved_by_account_admin
      elsif current_user.account_admin?
        f.input :approved_by_account_admin
      else
      end
      f.input(
        :roles,
        as: :select,
        collection: Role.user_roles,
        member_label: proc { |r| r.name.titlecase },
        hint: "Choose one role for user."
      )

      f.input :pref_header_image, :hint => "Display customer image in masthead?"
      f.input :pref_time_display, :as => :select, :collection => User.time_options
      f.input :pref_timezone, :as => :select, :collection => ActiveSupport::TimeZone.all
      f.input :pref_email_notifications
    end

    f.actions
  end

  action_item only: :show do
    InvitationLink.for(user, self)
  end

  index do
    column "Email" do |user|
      link_to user.email, edit_admin_user_path(user)
    end
    column :account
    column :roles do |user|
      ul { user.roles.each { |r| li r.name } }
    end
    column :approved_by_admin
    column :approved_by_account_admin
    column :invitation do |user|
      InvitationLink.for(user, self)
    end
    column :pref_email_notifications
    default_actions
  end

  show do
    attributes_table do
      row :account
      row :email
      row :approved_by_admin
      row :approved_by_account_admin
      row :confirmation_sent_at
      row :confirmed_at
      row :sign_in_count
      row :last_sign_in_at
      row :created_at
      row :updated_at
      row :roles do
        ul { user.roles.each { |r| li r.name } }
      end
    end

  end

  member_action(:invite, method: :post) do
    user = User.find(params[:id])
    if user.fully_approved?
      user.invite
      flash[:notice] = "Successfully sent inviation to #{user.email}"
    else
      flash[:error] = "#{user.email} is not approved."
    end
    redirect_to action: :index, controller: "admin/users"
  end

end

