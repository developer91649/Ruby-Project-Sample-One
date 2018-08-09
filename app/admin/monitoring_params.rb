ActiveAdmin.register MonitoringParam do
  config.sort_order = 'order_monitoring_asc'
  config.per_page = 200

  filter :title
  filter :qes_variable
  filter :account, :as => :select
  filter :param_type, :as => :select, :collection => MonitoringParam.types
  filter :category, :as => :select, :collection => MonitoringParam.categories
  filter :display_loco_detail, :as => :check_boxes
  filter :display_monitoring, :as => :check_boxes

  index do
    column :title, :sortable => :title do |param|
      link_to param.title, edit_admin_monitoring_param_path(param)
    end
    column :account
    column :locomotive_type
    column :order_loco_detail
    column :order_monitoring
    column "Code", :sortable => :spn do |field|
      "#{field.spn}-#{field.fmi}"
    end
    column :param_type
    column :category
    column :cummings_pgn
    column :qes_variable
    column :group
    column :units
    column :source
    column :chart_min
    column :threshold_max
    default_actions
  end

  collection_action :sort, :method => :post do
    params[:monitoring_params].each_with_index do |id, index|
      MonitoringParam.update( id, :order_monitoring => index + 1 )
      MonitoringParam.update( id, :order_loco_detail => index + 1 )
    end
    render :nothing => true
  end

  form do |f|
    f.inputs :name do
      if f.object.new_record?
        f.input :account
      end
      f.input :title
      f.input :description, :input_html => {:class => "ckeditor"}
      f.input :param_type, :as => :select, :collection => MonitoringParam.types
      f.input :category, :as => :select, :collection => MonitoringParam.categories
      f.input :spn, :label => "SPN"
      f.input :fmi, :label => "FMI"
      f.input :cummings_pgn
      f.input :qes_variable
      f.input :group
      f.input :units
      f.input :source
      f.input :percent_change
    end
    f.inputs :name => "Display" do
      f.input :display_loco_detail, :hint => "Show this parameter on the locomotive detail page in the list of parameters at the bottom of the page. Whether it appears in the Health or Status list depends on the Type chosen above."
      f.input :display_monitoring, :hint => "Show this parameter on the Monitoring chart pages. Whether it appears in the Health or Status list depends on the Type chosen above."
      # f.input :display_maintenance_monitoring, :hint => "Show this parameter on the Maintenance Monitoring page."
      f.input :order_loco_detail, :hint => "When parameters are dragged and dropped on the list view (in the admin),
      the order on the loco detail AND the monitoring (graph) lists is updated automatically to reflect the order of the rows.
      You can further edit the order by changing the numbers in these two order fields. Note: if you change these fields and then drag and drop the rows,
      the changes to the fields will the overriden by the drag and drop order of the rows."
      f.input :order_monitoring
      # f.input :order_maintenance_monitoring
    end
    f.inputs :name => "Maintenance Charts" do
      f.input :chart_min, :hint => "The start of the Y-axis"
      f.input :chart_max, :hint => "The top of the Y-axis"
      f.input :threshold_min, :hint => "Min line on chart"
      f.input :threshold_max, :hint => "Max line on chart"
    end
    f.inputs :name => "Target Anaysis Modes" do
      f.input :mode_power, :label => "Power", :as => :boolean
      f.input :mode_brake, :label => "Brake", :as => :boolean
      f.input :mode_fuel, :label => "Fuel", :as => :boolean
      f.input :mode_gps, :label => "GPS", :as => :boolean
      f.input :mode_loading, :label => "Loading", :as => :boolean
      f.input :mode_subsystem, :label => "Subsystem", :as => :boolean
      f.input :mode_wide, :label => "Wide", :as => :boolean
    end

    f.buttons
  end

  controller do
    def show(options={}, &block)
      jdata= {}
      monitoring_param = MonitoringParam.find(params[:id])
      jdata[:account_id], jdata[:category], jdata[:chart_max], jdata[:chart_min], jdata[:created_at], jdata[:cummings_pgn], jdata[:description], jdata[:display_loco_detail], jdata[:display_maintenance_monitoring],  jdata[:display_monitoring], jdata[:group], jdata[:mode_brake], jdata[:mode_fuel], jdata[:mode_gps], jdata[:mode_loading], jdata[:mode_power], jdata[:mode_subsystem], jdata[:mode_wide], jdata[:param_type], jdata[:percent_change], jdata[:qes_variable], jdata[:source], jdata[:threshold_max], jdata[:threshold_min], jdata[:title], jdata[:trainline], jdata[:units] =  monitoring_param.account_id, monitoring_param.category, monitoring_param.chart_max, monitoring_param.chart_min, monitoring_param.created_at, monitoring_param.cummings_pgn, monitoring_param.description, monitoring_param.display_loco_detail, monitoring_param.display_maintenance_monitoring,  monitoring_param.display_monitoring, monitoring_param.group, monitoring_param.mode_brake, monitoring_param.mode_fuel, monitoring_param.mode_gps, monitoring_param.mode_loading, monitoring_param.mode_power, monitoring_param.mode_subsystem, monitoring_param.mode_wide, monitoring_param.param_type, monitoring_param.percent_change, monitoring_param.qes_variable, monitoring_param.source, monitoring_param.threshold_max, monitoring_param.threshold_min, monitoring_param.title, monitoring_param.trainline, monitoring_param.units
      call = LIIS::Locomotive.new(account_id: monitoring_param.account_id, locomotive_id: 1)
      call.monitoring_params_upsert(monitoring_param.qes_variable,jdata.to_json)
      logger.info("The MonitoringParam is saved to the LIIS #{jdata}")
    rescue Exception => e
      logger.info e.message
      logger.info e.backtrace.join("<br>\r\n")
    end
  end


  member_action :edit_alarm_health_snapshot_faults do
    @monitoring_param = MonitoringParam.find(params[:id])
  end

  action_item only: [:show, :edit] do
    if _monitoring_param = MonitoringParam.find(params[:id])
      link_to(
        "AHS Faults",
        edit_alarm_health_snapshot_faults_admin_monitoring_param_path(
          _monitoring_param
        )
      )
    end
  end
end

