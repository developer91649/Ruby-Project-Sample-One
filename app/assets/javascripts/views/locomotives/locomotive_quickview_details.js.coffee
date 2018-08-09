class Cds.Views.LocomotiveQuickviewDetails extends Backbone.View
  template: JST['locomotives/locomotive_quickview_details']

  initialize: ->
    @user = @options.user

  render: ->
    $(@el).html(@template(loco: @model, user: @user))
    @$timeList = $(@el).find(".times-list")
    @addTimes()
    @addLocation()
    @updateStatus()
    this

  updateStatus: ->
    $status = @$(".loco-details-status")
    classList = $status.attr('class').split(/\s+/)
    for cssClass in classList
      hasLevel = /^level_/
      if hasLevel.exec(cssClass)
        $status.removeClass(cssClass)
    $status.addClass(@model.get("loco_status_class"))
    $status.find("img").attr("src", "/assets/#{@model.get("icon_image")}")
    color = @model.get("dark_color")
    @$(".loco-status").text("#{@model.get("loco_status_text")}").css("color": color)
    $("section.loco-status-section").removeClass("offline");
    $(".offline-message").removeClass("active");
    $(".fuel-consumption-list").removeClass("offline");
    if(@model.get("loco_status_text")=="Offline")
      $("section.loco-status-section").addClass("offline");
      $(".offline-message").addClass("active");
      $(".fuel-consumption-list").addClass("offline");

    @$(".total-faults").text(@model.get("total_faults"))

  addUTCTime: ->
    gpsTime = @model.get("time_utc_gps")
    if gpsTime is null
      gpsTime = @model.get("time_utc")
    # example: 2013-07-12T18:37:05Z-04:00
    utcTime = Cds.time.getTimeUTC(
      time: gpsTime
    )
    @$timeList.find(".utc-time em").text("GMT")
    @$timeList.find(".utc-time strong").text(utcTime)

  addLocoTime: ->
    locoTime = Cds.time.getLocoTime( locomotive: @model )
    @$timeList.find(".locomotive-time strong").text(locoTime)

  addPrefTime: ->
    gpsTime = @model.get("time_utc_gps")
    if gpsTime is null
      gpsTime = @model.get("time_utc")
    prefTime = Cds.time.getUserPrefTime(
      user: @user
      time: gpsTime
      locomotive: @model
    )
    userPrefTimeZone = @user.get("pref_timezone")
    # slice off the timezone offset for display
    # (GMT-07:00) Mountain Time (US & Canada)
    userPrefTimeZone = userPrefTimeZone.slice(12)
    # this is sometimes incorrect - from browser
    # tzAbbr = Cds.time.tzAbbr(new Date(prefTime))
    # @slicedTimezone = @timezonePref.slice(12)
    @$timeList.find(".preference-time em").text(userPrefTimeZone)
    @$timeList.find(".preference-time strong").text(prefTime)

  addLocation: ->
    @$(".loco-details-gps span").text(@model.get("gps"))
    @$(".loco-details-waypoint span").text(@model.get("waypoint"))

  addSelectedTimeDisplay: ->
    timeDisplay = @user.get("pref_time_display").toLowerCase()
    @$(".times-list").find(".#{timeDisplay}-time").addClass("chosen-pref")

  addTimes: ->
    # (GMT-07:00) Mountain Time (US & Canada)
    @timezonePref = @user.get("pref_timezone")
    @addUTCTime()
    @addLocoTime()
    @addPrefTime()
    @addSelectedTimeDisplay()

