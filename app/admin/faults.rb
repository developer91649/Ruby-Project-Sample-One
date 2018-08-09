ActiveAdmin.register Fault do

  index do
    column :title, :sortable => :title do |fault|
      link_to fault.title, edit_admin_fault_path(fault)
    end
    column :account
    column :locomotive_type
    column :code_display
    column :qes_variable
    column :cummins_variable
    column "SPN-FMI", :sortable => :spn do |field|
      "#{field.spn}-#{field.fmi}"
    end

    column :system, :sortable => :system
    column :severity

    column "Explanation" do |fault|
      truncate(fault.explanation, omision: "...", length: 100)
    end
    column "Locomotive Effect" do |fault|
      truncate(fault.locomotive_effect, omision: "...", length: 100)
    end
    column "Operator Action" do |fault|
      truncate(fault.operator_action, omision: "...", length: 100)
    end
    column "Maintainer Action" do |fault|
      truncate(fault.maintainer_action, omision: "...", length: 100)
    end
    default_actions
  end

  form do |f|
    f.inputs do
      if f.object.new_record?
        f.input :account
      end
      f.input :title
      f.input :system, :as => :select, :collection => System.for_account(current_tenant)
      f.input :locomotive_type
      # f.input :spn, :label => "SPN"
      # f.input :fmi, :label => "FMI"
      f.input :cummins_variable, :label => "Cummins Fault #"
      f.input :qes_variable, :label => "QES Fault #"
      f.input :code_display
      f.input :data_dictionary, :input_html => {:disabled => 'disabled'}
      f.input :severity, :as => :select, :collection => Fault::SEVERITY_LEVELS, :label => "Fault Level", :hint => "(0=Loco Offline, 1 = Critical Alarm, 2=Warning, 3=Message)"
      f.input :hidden
      f.input :needs_notification
      f.input :explanation, :input_html => {:class => "ckeditor"}
      f.input :locomotive_effect, :input_html => {:class => "ckeditor"}
      f.input :operator_action, :input_html => {:class => "ckeditor"}
      f.input :maintainer_action, :input_html => {:class => "ckeditor"}
    end

    f.buttons
  end

  controller do
    def show(options={}, &block)
      jdata,rdata = {},{}
      fault = Fault.find(params[:id])
      rdata[:fault_id],  rdata[:severity], rdata[:title], rdata[:hidden] = fault.code_display, fault.severity, fault.title, fault.hidden
      jdata[:fault_id], jdata[:data_dictionary], jdata[:severity], jdata[:title], jdata[:needs_notification], jdata[:hidden]  = fault.code_display, fault.data_dictionary, fault.severity, fault.title, fault.needs_notification, fault.hidden
      call = LIIS::Locomotive.new(account_id: fault.account_id, locomotive_id: 1)
      call.fault_upsert(fault.code_display,jdata.to_json)
      call.alarms_upsert(fault.code_display,rdata.to_json)
      logger.info("The Fault is saved to the LIIS #{jdata}")
      logger.info("The Alarm is saved to the LIIS #{rdata}")
    rescue Exception => e
      logger.info e.message
      logger.info e.backtrace.join("<br>\r\n")
    end
  end

  member_action :edit_alarm_health_snapshot_params do
    @fault = Fault.find(params[:id])
  end

  action_item only: [:show, :edit] do
    if _fault = Fault.find(params[:id])
      link_to(
        "AHS Params",
        edit_alarm_health_snapshot_params_admin_fault_path(_fault)
      )
    end
  end

end
