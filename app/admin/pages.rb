ActiveAdmin.register Page do
  index do
    column :title, :sortable => :title do |page|
      link_to page.title, edit_admin_page_path(page)
    end
    column :id
    default_actions
  end

  form do |f|
    f.inputs do
      f.input :title
      f.input :body, :input_html => {:class => "ckeditor"}
    end
    f.buttons
  end
end
