class Cds.Views.TargetAnalysisGPS extends Backbone.View
  template: JST["monitoring/target_analysis_g_p_s"]
  className: "dialog ta-dialog ta-gps"
  events:
    "click .close-btn": "destroy"
    "close": "close"
    "open": "open"
    "destroy": "destroy"

  initialize: ->
    @parent  = @options.parent
    @point   = @options.point
    @loco    = @options.loco
    @markers = []

  render: ->
    $el = @$el

    locals =
      point     : @point
      locoTitle : @options.loco.get("title")

    $el.html( @template( locals ) )
    $el.css
      borderColor: @point.series.color
    $el.find('thead th').css
      backgroundColor: @point.series.color

    dateOptions = [
      text: "24 Hours"
      hours: 24
    ,
      text: "2 Days"
      hours: 48
    ,
      text: "3 Days"
      hours: 72
    ]
    @dateRangeSelector = new Cds.Views.DateRangeSelector(
      to: moment.utc(@point.x)
      dateOptions: dateOptions
      range: false
      time: true
    )

    # Load up the map view
    @mapView = new Cds.Views.Map
      center: @point.getGPSCoords()
      zoom: 12

    @

  open: ->
    $el      = @$el
    modeMenu = @parent
    page     = modeMenu.parent
    $el.show()

    @dateRangeSelector.render().$el.appendTo ".map-options"
    @dateRangeSelector.$buttonGroup.addClass "btn-group-xs"
    @destroyMarkers()
    @loadGPSData()

    @dateRangeSelector.currentDateRange.on("change:from_date_raw", =>
      @updateFromDate()
      @destroyMarkers()
      @loadGPSData()
    , @)

    from = @dateRangeSelector.currentDateRange.get("from_date_raw")
    to   = @dateRangeSelector.currentDateRange.get("to_date_raw")

    $(".datetime-from").html "#{from.format("MMM D, HH:mm:ss")} <small>UTC</small>"
    $(".datetime-to").html "#{to.format("MMM D, HH:mm:ss")} <small>UTC</small>"

    # Attach the map to the dom
    $el.find('.dialog-section.map').append( @mapView.$el )

    # Render the map (order's important here—element's gotta be appended first)
    @mapView.render()

    # Add the point to the map
    new google.maps.Marker
      map      : @mapView.map
      position : @point.getGPSCoords()
      title    : @point.get("time_utc")
      icon     : Cds.mapping.getLocoMapIcon(@point.series.color)

    # @todo Refactor this out to happen at the page level
    if !page.hasChartButton("exit-ta")
      page.addChartButton(
        id:     "exit-ta"
        text:   "Exit Target Analysis"
        click: (e)->
          e.preventDefault()
          console.log "exit ta clicked"
          page.trigger("destroyTAReports")
      )

      page.once "destroyTAReports", (e)->
        $('.ta-dialog').trigger "destroy"


  currentDateRange: -> @dateRangeSelector.currentDateRange

  updateFromDate: ->
    from = @dateRangeSelector.currentDateRange.get("from_date_raw")
    $el = $(".datetime-from")
    $el.html "#{from.format("MMM D, HH:mm:ss")} <small>UTC</small>"

  loadGPSData: ->
    @loco.getTargetAnalysisGPS
      from : @currentDateRange().get("url_from")
      to   : @currentDateRange().get("url_to")
    @loco.targetAnalysisGPS.fetch
      beforeSend: (jqXHR, settings) =>
        @$el.find('.map').addClass("loading")
        jqXHR
      success: (collection, XHR) =>
        @$el.find('.map').removeClass("loading")
        collection.each (point) =>
          @addMapMarker point.getGPSCoords(), point.get("time")
      error: (collection, XHR)->
        @$el.find('.map').removeClass("loading")
        console.log XHR

  addMapMarker: (position, title = "") ->
    marker = new google.maps.Marker
      map      : @mapView.map
      position : position
      title    : title
      icon     :
        path: google.maps.SymbolPath.CIRCLE
        fillColor: @point.series.color
        fillOpacity: 0.8
        strokeColor: "white"
        strokeOpacity: 0.5
        strokeWeight: 1
        scale: 8
    @markers.push marker

  hideMarkers: ->
    _.each @markers, (marker) ->
      marker.setMap(null)

  showMarkers: ->
    _.each @markers, (marker) ->
      marker.setMap(@mapView.map)

  destroyMarkers: ->
    @hideMarkers()
    @markers = []

  # Close the modal
  close: ->
    @$el.remove() # Close the modal

  destroy: ->
    modeMenu = @parent
    page     = modeMenu.parent

    @point.flag(false)
    @point.mark(false) # Unmark the point
    @$el.trigger "close"
    if $('.ta-dialog').length < 1
      page.removeChartButton "exit-ta"
      page.paramChart.get("chart").selectedPointCount = 0
