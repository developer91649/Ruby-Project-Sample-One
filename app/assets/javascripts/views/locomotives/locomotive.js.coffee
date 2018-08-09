class Cds.Views.Locomotive extends Backbone.View

  template: JST["locomotives/locomotive"]
  tagName: "tr"
  id: -> "loco_#{@model.get("id")}"
  className: "locomotive_info"

  events:
    # "click .loconumber-td": "showLocomotive"
    "click .fault-summary-link-td": "showFaultSummary"
    "click .time-wrap": "showTimeList"
    "click .close-times-list": "closeTimeList"
    "click .times-list li": "changeUserTimeDisplayPref"

  initialize: ->
    @locomotive = @model
    @user = @options.user
    _.bindAll(@)
    @model.on(
      "change:status_locomotive": @updateStatus
      "change:total_faults": @updateTotalFaults
      "change:time_utc_last_alarm": @updateTime
      "change:waypoint": @waypoint
    )
    @user.on(
      "change:pref_time_display": @updateToTimeDisplayPref
    )

  render: ->
    $(@el).html( @template( locomotive: @model ) )
    @updateStatus()
    @updateTime()
    @updateWaypoint()
    @addToolTip()
    this

  updateWaypoint: ->
    waypoint = @model.get("waypoint")
    if waypoint is null
      waypoint = ""
    @$(".location-td").text(waypoint)

  updateTime: () ->
    alarm_time = @model.get("time_utc_last_alarm") ? new Date()
    time = Cds.time.getTimeByUserPref(
      user: @user
      time: alarm_time
      locomotive: @locomotive
    )
    @$(".time-wrap")
      .text(time)
      .attr("data-utc", moment.utc(time).valueOf())
    if @$(".times-list").length > 0
      @createTimeList()

  updateStatus: ->
    @setLevelClass()
    @_updateStatus()

  setLevelClass: ->
    classList = $(@el).attr('class').split(/\s+/)
    for cssClass in classList
      hasLevel = /^level_/
      if hasLevel.exec(cssClass)
        $(@el).removeClass(cssClass)

      $(@el).addClass(@model.statusClass())

  addToolTip: () ->
    @$(".locostatus-td").tooltip
      title: @model.statusDescription()
      container: ".dataTables_wrapper"

  _updateStatus: ->
    @$(".locostatus-td span")
      .attr("data-status", @model.get("status_locomotive"))
      .attr("data-sortvalue", @model.get("sort_value"))
      .text(@model.statusText())

  updateTotalFaults: ->
    @$(".fault-summary-link-td span.total_faults_style").text(@model.get("total_faults"))

  showLocomotive: (e) ->
    e.preventDefault()
    Backbone.history.navigate("locomotives/#{@model.get('id')}", true)

  showFaultSummary: (e) ->
    e.preventDefault()
    Backbone.history.navigate("locomotives/#{@model.get('id')}/fault-summary", true)

  addSelectedTimeDisplay: ->
    @$(".times-list li").removeClass("chosen-pref")
    timeDisplay = @user.get("pref_time_display").toLowerCase()
    @$(".times-list").find(".#{timeDisplay}-time").addClass("chosen-pref")

  createTimeList: () ->
    # on fault, get on time
    if @model.get("time_utc_on")?
      time = @model.get("time_utc_on")
    else
      time = @model.get("time_utc_last_alarm")
    times = Cds.time.getAllTimes(
      locomotive: @locomotive
      time: time
      user: @user
    )
    template = JST['time_list']
    _templ = template( times: times )
    @$(".time-list-wrap").empty().append(_templ).show()
    @addSelectedTimeDisplay()

  showTimeList: (e) ->
    $(".time-list-wrap").empty()
    @createTimeList()

  closeTimeList: (e) ->
    $(e.target).parent("ul").remove()

  changeUserTimeDisplayPref: (e) ->
    if $(e.target).is("li")
      $time = $(e.target)
    else
      $time = $(e.target).parent("li")
    $time.parent("ul").remove()
    pref = $time.attr("data-pref")
    userPref = @user.get("pref_time_display")
    @user.save( "pref_time_display", pref,
      error: (response) ->
        new Cds.Views.Alert(
          status: "error"
          msg: "There was a problem saving your user preference."
        )
      success: (response) ->
        new Cds.Views.Alert(
          status: "success"
          msg: "Your user time display preference was updated to: #{pref}."
        )
    )

  updateTableTimePref: () ->
    $text = $(".standard .header-time span")
    pref = @user.get("pref_time_display")
    pref = "(#{pref})"
    header = $text.text()
    findPref = /\((\w+)\)/
    $text.text( header.replace(findPref, pref) )

  updateToTimeDisplayPref: () ->
    @updateTableTimePref()
    @updateTime()
