# encoding: UTF-8
ActiveAdmin.register Locomotive do
  require 'zip/zip'

  index do
    column :title, :sortable => :title do |locomotive|
      link_to locomotive.title, edit_admin_locomotive_path(locomotive)
    end
    column :account
    column :id_assigned
    column :id
    column :locomotive_type
    column :commission_date
    column :description
    # column :config_file
    default_actions
  end

  form do |f|
    f.inputs do
      if f.object.new_record?
        f.input :account
      end
      f.input :title
      f.input :id_assigned
      f.input :locomotive_type
      f.input :commission_date, :as => :datepicker
      f.input :description
      f.input :send_map, :as => :boolean, :input_html => { :checked => false }
      f.input :send_config, :as => :boolean, :input_html => { :checked => false }
      f.input :config_file
      f.input :pref_measurement_system, :collection => Account.measurement_system_options
      f.input :pref_measurement_fuel, :collection => Account.measurement_fuel_options
    end
    f.actions
  end

  controller do
    def show(options={}, &block)
      if Rails.env.test?
        return
      end

      jdata                           = {}
      config                          = params[:locomotive]
      locomotive                      = Locomotive.find(params[:id])
      locomotive_id,account_id        = params[:id],locomotive.account_id
      file_path                       = File.join('public', 'logfiles',account_id.to_s,locomotive.id_assigned.to_s)
      call                            = LIIS::Locomotive.new(account_id: locomotive.account_id, locomotive_id: locomotive.id_assigned)
      jdata[:name]                    = locomotive.title
      jdata[:locomotive_name]         = locomotive.title
      jdata[:type]                    = locomotive.locomotive_type.name
      jdata[:key]                     = "#{account_id}-#{locomotive.id_assigned}"
      jdata[:time_utc_last_alarm]     = Time.now
      jdata[:time_utc]                = Time.now
      jdata[:pref_measurement_system] = locomotive.pref_measurement_system
      jdata[:fuel_units]              = locomotive.pref_measurement_fuel
      jdata[:gps]                     = "0,0"
      call.locomotive_upsert(jdata.to_json)
      logger.info "Config FilePath: #{file_path}"
      if locomotive.send_config === 1
        logger.info "***********************"
        begin
          FileUtils.mkpath file_path
          FileUtils.chmod_R 0777, file_path
          File.open(File.join(file_path, 'CommonConfiguration.config'), 'w') { |file| file.write(locomotive.config_file.encode('utf-8')) }
          file_list = ['CommonConfiguration.config']
          zipfile_name = "#{file_path}/CommonConfiguration.zip"
          if FileTest.exists?(zipfile_name)
           FileUtils.rm(zipfile_name)
          end
          if Rails.env.production? || Rails.env.staging?
            logger.info "~~~~~~~~~Prod~~~~~~~~~"
            system("zlibUtil #{File.join(file_path, 'CommonConfiguration.config')} #{file_path}/CommonConfiguration.zip")
            logger.info "~~ Filepath Production: #{File.join(file_path, 'CommonConfiguration.config')} #{file_path}/CommonConfiguration.zip"
          else
            logger.info "~~~~~~~~~Not Prod~~~~~~~~~~~"
            Zip::ZipFile.open(zipfile_name, Zip::ZipFile::CREATE) do |zipfile|
              file_list.each do |filename|
                zipfile.add(filename, file_path + '/' + filename)
              end
            end
          end
          logger.info zipfile_name
          logger.info FileTest.exists?(zipfile_name)
          if FileTest.exists?(File.join(file_path, 'CommonConfiguration.config')) && FileTest.exists?(zipfile_name)
           FileUtils.rm(File.join(file_path, 'CommonConfiguration.config'))
          end
        rescue => e
          logger.info e.message
          logger.info e.backtrace.join("<br>\r\n")
        end
        logger.info "~~~~~~~~~~~~~~~~~~~~~~~~~"
      end

      if locomotive.send_map === 1
        call.alarmsmap(locomotive.id_assigned,jdata.to_json)
      end

      begin
      locomotive.send_config = 0
      locomotive.send_map = 0

      locomotive.save!
      rescue => e
        logger.info e.message
        logger.info e.backtrace.join("<br>\r\n")
      end
    end
  end
end