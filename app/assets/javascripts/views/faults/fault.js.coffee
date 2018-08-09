class Cds.Views.Fault extends Cds.Views.Locomotive

  template: JST['faults/fault']
  tagName: 'tr'
  className: 'fault_entry'

  events:
    'click .fault-map-wrap-td a': 'triggerFaultMap'
    # 'click .diagnostics-link-td': 'showDiagnostics'
    "click .time-wrap": "showTimeList"
    "click .time-wrap": "showTimeList"
    "click .close-times-list": "closeTimeList"
    "click .times-list li": "changeUserTimeDisplayPref"

  initialize: ->
    _.bindAll(@)
    @user = @options.user
    @locomotive = @options.locomotive
    @model.on( "change:time_utc": @updateTime )
    @user.on( "change:pref_time_display": @updateToTimeDisplayPref )

  render: ->
    $(@el).html(@template(
      fault: @model,
      time: @addTime,
      timeUTC: @timeUTC,
      user: @user,
      locomotive: @locomotive
    ))
    @faultSeverityClass(@model)
    this

  faultSeverityClass: (fault) ->
    classList = $(@el).attr('class').split(/\s+/)
    for cssClass in classList
      hasLevel = /^level_/
      if hasLevel.exec(cssClass)
        $(@el).removeClass(cssClass)
    severity = Cds.faults.getSeverity(fault.get("severity"))
    $(@el).addClass(severity.fault_status_class)

  addTime: (user, time, locomotive) ->
    time = Cds.time.getTimeByUserPref(
      user: user
      time: time
      locomotive: locomotive
    )

  timeUTC: (time) ->
    moment.utc(time).valueOf()

  updateTime: () ->
    if @model.get("alarm_status") is 1
      timeON = Cds.time.getTimeByUserPref(
        user: @user
        time: @model.get("time_utc_on")
        locomotive: @locomotive
      )
      @$(".time-wrap").html("<span class=\"time time-on\">#{timeON}</span>")

    else
      timeON = Cds.time.getTimeByUserPref(
        user: @user
        time: @model.get("time_utc_on")
        locomotive: @locomotive
      )
      timeOFF = Cds.time.getTimeByUserPref(
        user: @user
        time: @model.get("time_utc_off")
        locomotive: @locomotive
      )
      times = """
              <span class="time time-on">#{timeON}</span>
              <span class="time time-off">#{timeOFF}</span>
              """
      @$(".time-td .time-wrap").html(times)

    @$(".time-td .time-wrap").attr("data-utc", moment.utc(timeON).valueOf())
    if @$(".times-list").length > 0
      @createTimeList()

  appendFaultMap: ->
    # temp - until feed is fixed in a latitude and longitude
    latlong = @model.get("gps").split(",")
    currentGps = new google.maps.LatLng(latlong[0], latlong[1])
    @map = new Cds.Models.Map(
      mapOptions:
        zoom: 14
        width: '400px'
        height: '400px'
        center: currentGps
        mapTypeId: google.maps.MapTypeId.SATELLITE
    )
    @map.set("currentGps", currentGps)
    map = new google.maps.Map( @$(".map-placeholder")[0], @map.get("mapOptions") )
    @map.set("map", map)

  centerMap: ->
    google.maps.event.trigger( @map.get("map"), 'resize' )
    @map.get("map").setCenter( @map.get("marker").getPosition() )

  addMarker: ->
    map = @map.get("map")
    marker = Cds.mapping.createFaultMapMarker( @options.locomotive, map, @model )
    @map.set( "marker", marker )
    google.maps.event.addDomListener(marker, 'click', (ev) =>
      Cds.mapping.openFaultMapInfoWindow(@options.locomotive, @model, map, marker, @user)
    )
    Cds.mapping.openFaultMapInfoWindow(@options.locomotive, @model, map, marker, @user)

  triggerFaultMap: (e) ->
    e.preventDefault()
    $tgt = $(e.target)
    @appendFaultMap()
    @addMarker()
    canvas = $tgt.next('.map-placeholder')
    canvas.lightbox_me(
      centered: true
      onLoad: =>
        @centerMap()
    )

  showDiagnostics: ->
    Backbone.history.navigate("locomotives/#{@model.get('locomotive_id')}/fault/#{@model.get('cms_id')}", true)


