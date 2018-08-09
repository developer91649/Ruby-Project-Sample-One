class Cds.Models.Locomotive extends Backbone.Model
  sync: (method, model, options)  ->
    if(method == "patch")
      method = "update"

    Backbone.sync.apply(@, [method, model, options])

  defaults:
    selected: false
    paramInstances: []

  urlRoot: '/api/locomotives'

  initialize: (attributes, options) ->
    @addStatusGraphics()
    @setCurrentLocoStatus()
    @on(
      "change:status_locomotive": @changeStatus
      "change:gps": @moveMarker
    )
    @locomotives = new Cds.Collections.Locomotives()
    @systemstatus = new Cds.Collections.SystemStatuses()
    @systemstatus.url = "/api/locomotives/#{@id}/system_statuses"
    @healthparams = new Cds.Collections.HealthParams()
    @healthparams.url = "/api/locomotives/#{@id}/healthparams/latest"
    @statusparams = new Cds.Collections.StatusParams()
    @statusparams.url = "/api/locomotives/#{@id}/statusparams/latest"
    @faultSummary = new Cds.Collections.Faults()
    @faultSummary.url = "/api/locomotives/#{@id}/faults/summary"
    @faultSummaryCritical = new Cds.Collections.Faults()
    @faultSummaryCritical.url = "/api/locomotives/#{@id}/faults/summary/critical"
    @faultSummaryWarningCritical = new Cds.Collections.Faults()
    @faultSummaryWarningCritical.url = "/api/locomotives/#{@id}/faults/summary/warning_critical"
    @faultSummaryMinute = new Cds.Collections.Faults()
    @faultSummaryMinute.url = "/api/locomotives/#{@id}/faults/summary/minute"
    @faultArchive = new Cds.Collections.Faults()
    @faultArchive.url = "/api/locomotives/#{@id}/faults/archive"
    @faultArchiveCritical = new Cds.Collections.Faults()
    @faultArchiveCritical.url = "/api/locomotives/#{@id}/faults/archive/critical"
    @faultArchiveWarningCritical = new Cds.Collections.Faults()
    @faultArchiveWarningCritical.url = "/api/locomotives/#{@id}/faults/archive/warning_critical"
    @faultArchiveMinute = new Cds.Collections.Faults()
    @faultArchiveMinute.url = "/api/locomotives/#{@id}/faults/archive/minute"

    @systems = new Cds.Collections.Systems()
    @systems.url = "/api/locomotives/#{@id}/systems/"
    @locomotive_data = new Cds.Collections.LocomotiveDatas()
    @locomotive_data.url = "/api/locomotives/#{@id}/locomotive_data/"
    @engine_data = new Cds.Collections.LocomotiveEngineDatas()
    @engine_data.url = "/api/locomotives/#{@id}/engine_data/"
    @locomotive_software = new Cds.Collections.LocomotiveSoftwares()
    @locomotive_software.url = "/api/locomotives/#{@id}/software/"
    @fuel_consumption = new Cds.Collections.FuelConsumptions()
    @fuel_consumption.url = "/api/locomotives/#{@id}/fuel_consumption/"
    @fuel_history = new Cds.Collections.FuelHistories()
    @fuel_history.url = "/api/locomotives/#{@id}/fuel_history/"
    _.bindAll(@)

  removeSelectedLoco: () ->
    @collection.removeSelected(@)

  setSelectedLoco: () ->
    isSet = @collection.setSelected(@)

  # set text and classes for current severity
  setCurrentLocoStatus: () ->
    status = Cds.locomotives.getCurrentSeverity(@getStatusIndex())
    @set("sort_value", status.sort_value)
    @set("loco_status_class", status.loco_status_class)
    @set("loco_status_text", status.loco_status_text)
    @set("loco_status_desc", status.loco_status_desc)

  getStatusIndex: ->
    if @isOutOfService()
      6
    else
      @get("status_locomotive")

  addStatusGraphics : ->
    graphics = Cds.mapping.getLocoStatusGraphics(@get("status_locomotive"))
    @set(graphics)

  initMonitoringChart: (opts) ->
    if opts.type is "health"
      @paramsChart = new Cds.Collections.HealthParams()
      @paramsChart.url = "/api/locomotives/#{@id}/healthparams/#{opts.paramVariable}/"
    else if opts.type is "status"
      @paramsChart = new Cds.Collections.StatusParams()
      @paramsChart.url = "/api/locomotives/#{@id}/statusparams/#{opts.paramVariable}"
    @paramsChart.locomotive = @
    return @paramsChart

  getCsvExportUrl: (opts)->
    if opts.type is 'health' 
      "/api/locomotives/#{@id}/healthparams/#{opts.paramVariable}.zip"
    else if opts.type is 'status'
      "/api/locomotives/#{@id}/statusparams/#{opts.paramVariable}.zip"
    else
      ''

  moveMarker: ->
    marker = @get("marker")
    if marker?
      gps = @get("gps")
      gps = gps.split(",")
      latitude = gps[0]
      longitude = gps[1]
      latlng = new google.maps.LatLng(latitude, longitude)
      # VIEW CHANGE
      marker.setPosition latlng

  changeStatus: ->
    new_status = @get("status_locomotive")
    if new_status is null
      sort_value = 20
    else
      sort_value = new_status.sort_value
    @set("sort_value", sort_value)
    @setCurrentLocoStatus()
    @addStatusGraphics()
    marker = @get("marker")
    if marker?
      icon = marker.getIcon()
      # change Google Maps icon
      # icon.url = "/assets/#{@get("locomotive_image")}"
      icon.fillColor = @get("color")
      # MAP VIEW CHANGE
      marker.setIcon icon

  getLogFiles: (options) ->
    @logfiles = new Cds.Collections.Logfiles()
    @logfiles.url = "/api/locomotives/#{@id}/systems/#{options.system_id}/logfiles"

  getSendFileFlags: (options) ->
    @sendFileFlags = new Cds.Collections.SendFileFlags()
    @sendFileFlags.url = "/api/locomotives/#{@id}/systems/#{options.system_id}/send_file_flags"

  getTargetAnalysisParams: (options) ->
    @targetAnalysisParams = new Cds.Collections.TargetAnalysisParams()
    @targetAnalysisParams.url = "/api/locomotives/#{@id}/target_analysis?mode=#{options.mode}&at=#{options.datetime}"

  getSubsystemHistories: (options) ->
    @subsystemHistories = new Cds.Collections.SubsystemHistories()
    @subsystemHistories.url = "/api/locomotives/#{@id}/subsystem_histories/#{options.datetime}"

  getLoadingHistories: (options) ->
    @loadingHistories = new Cds.Collections.SubsystemHistories()
    @loadingHistories.url = "/api/locomotives/#{@id}/loading_histories/#{options.datetime}"

  getTargetAnalysisGPS: (options) ->
    @targetAnalysisGPS = new Cds.Collections.TargetAnalysisGPS()
    @targetAnalysisGPS.url = "/api/locomotives/#{@id}/target_analysis/gps?from=#{options.from}&to=#{options.to}"

  getAlarmHealthSnapshots: (options) ->
    @alarmHealthSnapshots = new Cds.Collections.AlarmHealthSnapshots()
    @alarmHealthSnapshots.url = "/api/locomotives/#{@id}/alarm_health_snapshot?at=#{options.datetime}&fault_id=#{options.fault_id}"

  # Long poll for loco assets
  # start with empty array, always longpoll automatically for gps/locomotive
  # other options ["systems", "health", "status"]
  # 1000 * 60 * @invervalMinutes
  startLongPollingAssets: (opts={}) ->
    if opts.interval? then interval = 1000 * 60 * opts.interval else interval = 300
    pollOptions =
      delay: interval
    _.each(opts.whatToPoll, (asset) =>
      poller = Backbone.Poller.get(@[asset], pollOptions)
      poller.on('success', (collection) =>
        if opts[asset]?
          opts[asset].beforeCallback(collection)
      )
      poller.start()
    )

  isGpsOnline: ->
    @get("status_gps") == 1

  isOutOfService: ->
    @get("out_of_service") == true

  toggleOutOfService: (options) ->
    @setOutOfService(!@isOutOfService(), options)

  setOutOfService: (val, options = {}) ->
    attributes = out_of_service: val
    options.patch = true

    @save(attributes, options)
    @setCurrentLocoStatus()

  statusText: ->
    @get("loco_status_text")

  statusClass: ->
    @get("loco_status_class")

  statusDescription: ->
    @get("loco_status_desc")

# Static Locomotives from Rails feed
class Cds.Models.LocomotiveStatic extends Cds.Models.Locomotive
  urlRoot: '/api/locomotives_all'
