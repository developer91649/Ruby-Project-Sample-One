class Cds.Views.LocomotivesIndex extends Backbone.View
  template: JST['locomotives/index']
  events:
    'click #toggle-fleetmap': 'initFleetMap'
    'click .fleet-usage-rpt-btn a': 'showDatePicker'

  initialize: ->
    @user = @options.user
    @account_id = @collection.models[0].get("account_id")

  render : ->
    $(@el).html(@template(user: @user, account_id: @account_id))
    @collection.each(@appendLocomotive)
    @hideLoader()
    @startLocoPoll()
    @addDataTables()
    this

  hideLoader: () ->
    @$(".table-loading").hide()

  startLocoPoll: () ->
    poller = Backbone.Poller.get(@collection, delay: 5000)
    poller.on('success', (model) =>
      $sortedBy = @$(".locomotives").find("th[aria-sort]")
      sortedByIndex = $sortedBy.index()
      longSortDirection = $sortedBy.attr("aria-sort")
      if longSortDirection is "ascending"
        sortDirection = "asc"
      else
        sortDirection = "desc"
      @locomotivesTable.fnSort( [ [sortedByIndex, sortDirection] ] )
    )
    poller.start()

  initFleetMap: (e) ->
    @appendMap()
    map = @map.get("map")
    overlay = new google.maps.OverlayView()
    overlay.draw = ->
    overlay.setMap map

    google.maps.event.addListener map, 'idle', =>
      @addMarkers(overlay)
    google.maps.event.addListenerOnce map, 'idle', =>
      map.fitBounds( @map.get("bounds") )

    @toggleMap(e)

  centerMap: ->
    google.maps.event.trigger( @map.get("map"), 'resize' )
    @map.get("map").fitBounds( @map.get("bounds") )

  appendLocomotive: (locomotive) =>
    view = new Cds.Views.Locomotive(
      model: locomotive
      user: @user
    )

    @$('.locomotives tbody').append(view.render().el)

  addMarkers: (overlay)->
    map = @map.get("map")

    _.each @map.get("markers"), (marker, i, markers) ->
      marker.setMap(null)
      google.maps.event.clearInstanceListeners(marker)
    @map.set "markers", []

    if overlay.getProjection
      @collection.each (locomotive) -> locomotive.set "latlng", new google.maps.LatLng( locomotive.get("latitude"), locomotive.get("longitude") )

      @collection.each (locomotive) =>
        locomotives = [locomotive]
        thisPixelPosition = overlay.getProjection().fromLatLngToContainerPixel(locomotive.get("latlng"))
        latLong = new google.maps.LatLng( locomotive.get("latitude"), locomotive.get("longitude") )
        bounds = @map.get("bounds")
        @collection.each (otherLoco) =>
          return if otherLoco.id is locomotive.id
          otherLocoPixelPosition = overlay.getProjection().fromLatLngToContainerPixel(otherLoco.get("latlng"))
          if Math.abs(thisPixelPosition.x - otherLocoPixelPosition.x) < 15 and Math.abs(thisPixelPosition.y - otherLocoPixelPosition.y) < 15
            locomotives.push otherLoco

        locomotives = _.sortBy(locomotives, (l) -> l.id)

        @map.set("bounds", bounds.extend(latLong) )
        marker = Cds.mapping.createLocoMapMarker( locomotive, map )
        @map.get("markers").push( marker )
        google.maps.event.addDomListener( marker, 'click', (ev) =>
          Cds.mapping.openFullLocoMapInfoWindow( locomotives, map, marker, @user )
        )
        google.maps.event.addDomListener( marker, 'mouseover', (ev) =>
          Cds.mapping.openLocoMapInfoWindow( locomotives, map, marker, @user )
        )
        google.maps.event.addDomListener( marker, 'mouseout', (ev) =>
          Cds.mapping.closeLocoMapInfoWindow( locomotives, map, marker, @user )
        )

  appendMap: ->
    @map = new Cds.Models.Map(
      mapOptions:
        zoom: 14
        width: '940px'
        height: '500px'
        center: new google.maps.LatLng(43.619922,-116.59687)
        mapTypeId: google.maps.MapTypeId.SATELLITE
    )
    googleMap = new google.maps.Map( @$("#map-canvas")[0], @map.get("mapOptions") )
    @map.set("map",  googleMap)

  addDataTables: () ->
    @locomotivesTable = @$(".locomotives").dataTable(
      oLanguage:
        sSearch: "Search:"
        sEmptyTable: "There are no locomotives."
      bLengthChange: false
      bPaginate: false
      bAutoWidth: false
      bInfo: false
      aoColumns: [
        # locomotive name
        null,
        # status
        null
        # type
        { sType: "data-sortvalue" },
        # location
        { sType: "data-sortvalue" },
        # last fault time
        { sType: "data-utc" },
        # active faults
        { bSortable: false },
      ]
      fnDrawCallback: (table) ->
        # push out-of-service locos to the bottom
        $(table.nTable).find("tr").each (i, row) ->
          if $(row).hasClass("level_out-of-service")
            $(table.nTable).append(row)
    )

  addSeverityFilter: ->
    self = @
    severityEls =
      """
      <div class="severity-filter">
        <select class="form-control">
          <option value="Show All">Show All</option>
          <option value="Critical">Critical</option>
          <option value="Warning">Warning</option>
          <option value="Message">Message</option>
        </select>
      </div>
      """
    @$(".summary-locomotive-filter-wrap").prepend(severityEls)
    @$(".severity-filter option").each( () ->
      if $(@).text() == self.prefSeverityFilter
        $(@).parent("select").val($(@).text())
    )

  showDatePicker: (e) ->
    $(e.target).parent().find(".datepicker-popup").fadeIn()
    $datePicker = $(e.target).parent().find("#datepicker").fadeIn()
    @addDatePickers($datePicker)
    @addSeverityFilter()

  addDatePickers: ($el) ->
    self = @
    chosenToggle = false
    fromDate = moment()
    toDate = moment()
    chosenDates = Cds.time.getDateSelectionByDays(fromDate, toDate)
    $el.datepicker(
      numberOfMonths: 3
      maxDate: '+0m +0w'
      minDate: new Date(2013, 1 - 1, 1)
      altFormat: "MM d, yy"
      beforeShowDay: (date) ->
        # disable dates before chosen from date, if one has been chosen
        if chosenToggle is true
          chosenFromDateUnix = fromDate.format("X")
          calendarDateUnix = moment(date).format("X")
          if chosenFromDateUnix > calendarDateUnix
            return [false]
        year = moment(date).format("YYYY") * 1
        month = moment(date).format("M") * 1
        day = moment(date).format("D") * 1
        i = 0
        # match chosen days to add highlightening
        while i < chosenDates.length
          return [true, "ui-state-chosen"] if year is chosenDates[i][0] and month is chosenDates[i][1] and day is chosenDates[i][2]
          ++i
        [true]
      onSelect: (date, inst) ->
        toDate =  moment(date)
        if chosenToggle is false
          fromDate =  moment(date)
          chosenToggle = true
        else
          chosenToggle = false
          self.resetDatePicker(@)
          self.fetchFleetReport(fromDate, toDate)
        chosenDates = Cds.time.getDateSelectionByDays(fromDate, toDate)
        inst.settings.beforeShowDay(date)
    )

  resetDatePicker: (tgt) ->
    $(tgt).parentsUntil(".date-picker-wrap").hide()
    $(tgt).datepicker( "destroy" )


  fetchFleetReport: (fromDate, toDate) ->
    $modal = @$('#loadingFleetReportModal')
    $modal.modal('show')
    $modelContent = $modal.find(".modal-body")
    $modelContent.html("<div class='modal-loading'>Fetching fleet report ...</div>")
    fleetReport = $.ajax
      type: "GET"
      url: "/api/fleet_report"
      data:
        from: fromDate.format("YYYY-MM-DD")
        to: toDate.format("YYYY-MM-DD")
    fleetReport.fail (jqXHR, textStatus) ->
      $modelContent.text("There was an error: #{jqXHR.status} #{jqXHR.statusText}")
    fleetReport.done (msg) ->
      filePath = msg.url
      $modelContent.html("The file is ready. <a class='btn btn-default' href='#{filePath}'>Download File</a>")

_.extend(Cds.Views.LocomotivesIndex.prototype, Cds.Mixins.UI)
