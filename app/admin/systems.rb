ActiveAdmin.register System do

  index do
    column "Name" do |system|
      link_to system.name, edit_admin_system_path(system)
    end
    column :id
    column :id_assigned
    column :account
    column :locomotive_type
    default_actions
  end

  form do |f|
    f.inputs do
      if f.object.new_record?
        f.input :account
      end
      f.input :name
      f.input :id_assigned
      f.input :locomotive_type
    end
    f.buttons
  end

  controller do
    def show(options={}, &block)
      if Rails.env.test?
        return
      end

      jdata  = {}
      system = System.find(params[:id])
      call   = LIIS::Locomotive.new(account_id: 1, locomotive_id: 1)
      system.attributes.each {|k,v| jdata[k] = v}
      jdata.delete :id
      call.system_upsert(jdata.to_json)
    end
  end
end
