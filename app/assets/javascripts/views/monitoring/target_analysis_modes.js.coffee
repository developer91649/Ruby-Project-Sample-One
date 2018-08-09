class Cds.Views.TargetAnalysisModes extends Backbone.View
  template: JST["monitoring/target_analysis_modes"]
  className: "modes-wrap"
  events:
    "click .close-btn": "cancelModes"
    "click ul.modes li a.target" : "openTargetOverlay"
    "click ul.modes li a.history" : "openHistoryOverlay"
    "click ul.modes li a.loading-history" : "openLoadingOverlay"
    "click .toggle-critical-alarms:not(.disabled)" : "toggleCriticalAlarms"
    "click #show-gps" : "openGPSOverlay"
    "cancel": "cancelModes"
    "close": "closeModes"

  initialize: ->
    @parent = @options.parent
    @point  = @options.point
    @loco   = @options.loco

  render: ->
    $(@el).html( @template
      panelPointData: @options.panelPointData
      modes: @collection.toJSON()
      criticalAlarm: @point.isCriticalAlarm()
      series: @point.series
    )

    $tooltip = $(@point.series.chart.container).find('.highcharts-tooltip')
    $(@el).css
      top: $tooltip.offset().top
      left: $tooltip.offset().left
      width: $tooltip.find("> span").width() + 17 # Account for container padding
      borderColor: @point.series.color

    @loadAlarms(JSON.parse(@point.get("active_alarms"))) if @point.isCriticalAlarm()
    return @

  # Handle cancel events (close button, new point selection)
  cancelModes: ->
    @point.flag(false)
    $(@el).trigger("close")

  ###
  Load alarm data from CMS

  @param {array} qes_variables
  ###
  loadAlarms: (qes_variables)->
    # Get the Snapshot
    faults     = new Cds.Collections.Faults
    faults.url = "/api/faults/#{qes_variables.join(",")}"
    modesView  = @

    faults.fetch(
      success: (result)-> modesView.showFaults(result)
    )

  ###
  @param {Cds.Collections.Faults} faults
  ###
  showFaults: (faults)->
    $modesViewElement          = $(@el)
    $criticalAlarm             = $modesViewElement.find ".critical-alarm-wrap"
    $criticalAlarmNotification = $criticalAlarm.find ".critical-alarm-notification"
    $criticalAlarmDetails      = $criticalAlarm.find ".critical-alarm-details"
    $criticalAlarms            = $criticalAlarm.find "ul.critical-alarms"
    loco_id                    = @loco.id
    time_utc                   = @point.get("time_utc")

    faults.each (fault)->
      $criticalAlarms.append(new Cds.Views.AlarmLi(
        loco_id  : loco_id
        fault    : fault
        time_utc : time_utc
      ).render().el) if fault.get("severity") == 1

    $criticalAlarm.css 'height', $criticalAlarmNotification.outerHeight()
    $criticalAlarm.animate
      height: $criticalAlarmDetails.outerHeight()
    $criticalAlarmNotification.animate
      marginTop: 0 - $criticalAlarmNotification.outerHeight()

  # Close the popover
  closeModes: ->
    $(@el).remove()

  # Open mode report modal
  openTargetOverlay: (e)->
    e.preventDefault()

    target_mode = $(e.target).attr('href')
    mode = @collection.findWhere(value: target_mode)
    point = @point
    $el = @$el

    viewParams =
      parent : @
      point  : @point
      loco   : @loco
      mode   : mode

    # Get the Target Analysis Params
    @loco.getTargetAnalysisParams(
      mode     : mode.get("shortName")
      datetime : encodeURIComponent(@point.get("time_utc"))
    )

    point.mark(true) # Mark the point with an identifier
    $el.trigger("close") # Close the dropdown
    reportView = new Cds.Views.TargetAnalysisReport(viewParams) # Create a view instance

    $reportViewElement = $(reportView.render().el)
    $reportViewElement.appendTo "body"
    $reportViewElement.draggable(
      snap: true
      handle: ".dialog-header"
    )
    $reportViewElement.trigger "open"

    $reportViewElement.position(
      my: "center"
      at: "center"
      of: window
    )

    @loco.targetAnalysisParams.fetch(
      success: (result)->
        reportView.displayData result,
          template: JST["monitoring/target_analysis_data"]
      error: (a, b, c)->
        alert "#{JSON.parse(b.responseText).errors.join("\n")}"
        $el.trigger("cancel") # Cancel the dropdown
    )

  # Open mode report modal
  openHistoryOverlay: (e)->
    e.preventDefault()

    target_mode = $(e.target).attr('href')
    mode = @collection.findWhere(value: target_mode)

    # Get the Target Analysis Params
    @loco.getSubsystemHistories(
      datetime : encodeURIComponent(@point.get("time_utc"))
    )

    @closeDropdownAndMarkPoint()

    reportView = @createReportView(
      parent : @
      point  : @point
      loco   : @loco
      mode   : mode
    )

    @loco.subsystemHistories.fetch(

      success: (result)->
        reportView.displayData result,
          template: JST["monitoring/subsystem_data"]
          displayedParams:
            aess: "AESS"
            cds: "CDS"
            event_recorder: "Event Recorder"
            gps: "GPS"
            qes: "QES"

      error: (a, b, c) =>
        alert "#{JSON.parse(b.responseText).errors.join("\n")}"
        @$el.trigger("cancel") # Cancel the dropdown
    )

  closeDropdownAndMarkPoint: () ->
    @point.mark(true) # Mark the point with an identifier
    @$el.trigger("close") # Close the dropdown

  openLoadingOverlay: (e) ->
    e.preventDefault()

    target_mode = $(e.target).attr('href')
    mode = @collection.findWhere(value: target_mode)

    # Get the Target Analysis Params
    @loco.getLoadingHistories(
      datetime : encodeURIComponent(@point.get("time_utc"))
    )

    @closeDropdownAndMarkPoint()

    reportView = @createReportView(
      parent : @
      point  : @point
      loco   : @loco
      mode   : mode
    )

    @loco.loadingHistories.fetch(

      success: (result)->
        reportView.displayData result,
          template: JST["monitoring/subsystem_data"]
          displayedParams: {}

      error: (a, b, c) =>
        alert "#{JSON.parse(b.responseText).errors.join("\n")}"
        @$el.trigger("cancel") # Cancel the dropdown

    )

  createReportView: (viewParams) ->
    reportView = new Cds.Views.TargetAnalysisReport(viewParams) # Create a view instance

    $reportViewElement = $(reportView.render().el)
    $reportViewElement.addClass "subsystem-history"
    $reportViewElement.appendTo "body"
    $reportViewElement.draggable(snap: true, handle: ".dialog-header")
    $reportViewElement.trigger "open"

    $reportViewElement.position(
      my: "center"
      at: "center"
      of: window
    )

    reportView

  openGPSOverlay: (e)->
    e.preventDefault()

    viewParams =
      parent : @
      point  : @point
      loco   : @loco

    @point.mark(true) # Mark the point with an identifier

    gpsView = new Cds.Views.TargetAnalysisGPS(viewParams)
    gpsView.render()

    $gpsViewElement = gpsView.$el
    $gpsViewElement.appendTo "body"
    $gpsViewElement.draggable
      snap: true
      handle: ".dialog-header"
      cancel: '.map, input'
    $gpsViewElement.trigger "open"
    $gpsViewElement.position
      my: "center"
      at: "center"
      of: window

    @$el.trigger("close") # Close the dropdown

  toggleCriticalAlarms: (e)->
    e.preventDefault()

    @point.series.criticalAlarmsEnabled = !@point.series.criticalAlarmsEnabled

    flagOptions =
      enabled: true
      symbol: "flag"
      fillColor: "#b72126"
      lineColor: "#b72126"
      lineWidth: 0
      radius: 10

    marker = if @point.series.criticalAlarmsEnabled then $.extend({
      states:
        hover: flagOptions
        select: flagOptions
    }, flagOptions) else @point.series.options.marker

    _.each @point.series.data, (point, data)->
      point.update(marker: marker, false) if point.isCriticalAlarm()

    @point.series.chart.redraw()

    @$el.trigger("cancel")
