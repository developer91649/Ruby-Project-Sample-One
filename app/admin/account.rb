ActiveAdmin.register Account do

  index do
    column :id
    column :name, :sortable => :name do |account|
      link_to account.name, edit_admin_account_path(account)
    end
    column :subdomain
    column :liis_id
    default_actions
  end

  form do |f|
    f.inputs "Details" do
      f.input :name
      f.input :subdomain
      f.input :liis_id, label: "LIIS id"

      img = f.object.header_image.nil? ?
        f.template.content_tag(:span, "no image yet") :
        f.template.image_tag(f.object.header_image.url(:thumb))

      f.input(:header_image, as: :file, hint: :img)

      f.input :company_address_1
      f.input :company_address_2
      f.input :company_city
      f.input :company_state
      f.input :company_zip
      f.input :company_country
      f.input :company_phone
      f.input :company_fax
      f.input :company_email
      f.input :company_url
      f.input :pref_measurement_system, :collection => Account.measurement_system_options
    end

    f.inputs "Enabled Features" do
      f.input(
        :roles,
        label: false,
        as: :check_boxes,
        member_label: proc { |r| r.name.humanize }
      )
    end

    f.buttons
  end

  show do
    attributes_table do
      row :id
      row :name
      row :subdomain
      row "LIIS id" do
        content_tag(:span, account.liis_id)
      end

      row :header_image do
        account.header_image.exists? ?
          image_tag(account.header_image.url(:thumb)) :
          content_tag(:i, "No image yet.")
      end

      row :company_address_1
      row :company_address_2
      row :company_city
      row :company_state
      row :company_country
      row :company_zip
      row :company_phone
      row :company_fax
      row :company_email
      row :company_url
      row :pref_measurement_system

      row :enabled_features do
        ul { account.roles.each { |r| li r.name.humanize } }
      end
    end
  end
end

