# encoding: UTF-8
ActiveAdmin.register LocomotiveType do

   index do
    column :id
    column :name, :sortable => :title do |locomotive_type|
      link_to locomotive_type.name, edit_admin_locomotive_type_path(locomotive_type)
    end
    column :engine_count
    column :description

    default_actions
  end

  form do |f|
    f.inputs :name => "General" do
      f.input :name, :hint => "ex: `MP33C` or `MP40PHTC-T4`"
      f.input :description, :hint => "ex: `Single Engine Diesel`, `Dual Engine Diesel`, `Cummins`, `Steam Locomotive`"
      f.input :engine_count, :as => :select, :collection => [1,2], :hint => "For engine params on dual engine remember to separate engine params by a comma and double them up, ex: 'ai24,ai25'"
    end

    f.inputs :name => "Environmental Values" do
      f.input :param_ambient_air, :hint => "ex: `ai20`"
    end

    f.inputs :name => "Power and Velocity" do
      f.input :param_speed, :hint => "ex: `mi5`"
      f.input :param_horsepower, :hint => "ex: `ai44`"
      f.input :param_rpm, :hint => "Prime Mover ~ ex: `ai35`"
      f.input :param_mg_power_out, :hint => "ex: `ai34`"
      f.input :param_hep_power, :hint => "ex: `ai139`"
      f.input :param_aux_power, :hint => "ex: `ai145`"
      f.input :engine_kwhrs_label, :hint => "ex: `lkwh`"
      f.input :param_status_aess, :hint => "ex: `mi44`"
      f.input :param_throttle_position, :hint => "ex: `mi0`"
      f.input :param_blendedbrake, :hint => "ex: `di98`"
    end

    f.inputs :name => "Locomotive" do
      f.input :param_trainlinelt, :hint => "ex: `di132`"
      f.input :param_trainlinert, :hint => "ex: `di133`"
    end

    f.inputs :name => "Fuel" do
      f.input :param_fuel_level, :hint => "ex: `mi14`"
      f.input :param_fuel_consumption, :hint => "ex: `ai73`"
      f.input :fuel_tank_size, :hint => "ex: `10000`"
    end

    f.inputs :name => "REA Map" do
      f.input :rea_map, :hint => "ex: `0647_20151029001707_GOT.REA` (file to use for testing this locomotive type)"
      f.input :rea_struct, :hint => "ex: `ac1s,td8b,st1b,sv1b,af1s,ag2s,ai220s,ao0s,di11s,do16b,mi74s,hs16s` (derived from map, and disabled for modification in admin)", :input_html => { :disabled => true }
    end

    f.inputs :name => "Show in Locomotive Detail?" do
      f.input :param_engine_kwhrs, :label => "Param Engine KW Hours", :as => :boolean
      f.input :param_engine_hours, :label => "Param Engine Hours", :as => :boolean
      f.input :param_odom, :label => "Odometer", :as => :boolean
    end
    f.actions
  end

  controller do
    def show(options={}, &block)
      if Rails.env.test?
        return
      end

      jdata          = {}
      locomotivetype = LocomotiveType.find(params[:id])
      call           = LIIS::Locomotive.new(account_id: 1, locomotive_id: 1)
      locomotivetype.attributes.each {|k,v| jdata[k] = v}
      jdata.delete :id
      call.type_upsert(jdata.to_json)
    end
  end
end