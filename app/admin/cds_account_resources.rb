ActiveAdmin.register CdsAccountResource do
  config.sort_order = 'position_asc'

  index do
    column :title, :sortable => :title do |resource|
      link_to resource.title, edit_admin_cds_account_resource_path(resource)
    end
    column :account
    column :category
    column :file_file_name
    column :link_url
    column :position
  end

  form :html => { :enctype => "multipart/form-data" } do |f|
    f.inputs do
      if f.object.new_record?
        f.input :account
      end
      f.input :category_id, :as => :select, :collection => Category.all
      f.input :title
      f.input :file, :as => :file
      f.input :link_url
      f.buttons
    end
  end


  collection_action :sort, :method => :post do
    params[:cds_account_resource].each_with_index do |id, index|
      CdsAccountResource.update_all(['position=?', index+1], ['id=?', id])
    end
    render :nothing => true
  end
end
