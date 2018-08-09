class Cds.Views.LocomotivesReports extends Backbone.View
  template: JST['locomotives/render_reports']
  events:
    'click .fleet_link': 'renderFleetReport'
    'click .excess_report_link': 'renderExcessReport'
    'click .reli_report_link': 'renderReliReport'
    'click .fleet_set': 'renderFleetModal'
    'click .excess_set': 'renderExcessModal'
    'click .reli_set': 'renderReliabilityModal'

  initialize: ->
    @user = @options.user
    @account_id = @collection.models[0].get("account_id")

  render : ->
    $(@el).html(@template(user: @user, account_id: @account_id))
    @collection.each(@appendLocomotive)
    @hideLoader()
    @$('.selectpicker').selectpicker()
    @$('#timepicker1').timepicker()
    @$('.reports-row').hide()
    @$('select').timezones()
    this


  renderFleetReport: (e) ->
    e.preventDefault()
    Backbone.history.navigate("reports/fleet-report", true)

  renderExcessReport: (e) ->
    e.preventDefault()
    Backbone.history.navigate("reports/excess-idle-report", true)

  renderReliReport: (e) ->
    e.preventDefault()
    Backbone.history.navigate("reports/reliability-report", true)

  renderFleetModal: () ->
    $('#confirm-fleet-set-modal').modal('show')

  renderExcessModal: () ->
    $('#confirm-excess-set-modal').modal('show')

  renderReliabilityModal: () ->
    $('#confirm-reliability-set-modal').modal('show')

  hideLoader: () ->
    @$(".table-loading").hide()

  appendLocomotive: (locomotive) =>
    view = new Cds.Views.Locomotive(
      model: locomotive
      user: @user
    )
    @$('.locomotives tbody').append(view.render().el)


#   addMarkers: (overlay)->
#     map = @map.get("map")

#     _.each @map.get("markers"), (marker, i, markers) ->
#       marker.setMap(null)
#       google.maps.event.clearInstanceListeners(marker)
#     @map.set "markers", []

#     if overlay.getProjection
#       @collection.each (locomotive) -> locomotive.set "latlng", new google.maps.LatLng( locomotive.get("latitude"), locomotive.get("longitude") )

#       @collection.each (locomotive) =>
#         locomotives = [locomotive]
#         thisPixelPosition = overlay.getProjection().fromLatLngToContainerPixel(locomotive.get("latlng"))
#         latLong = new google.maps.LatLng( locomotive.get("latitude"), locomotive.get("longitude") )
#         bounds = @map.get("bounds")
#         @collection.each (otherLoco) =>
#           return if otherLoco.id is locomotive.id
#           otherLocoPixelPosition = overlay.getProjection().fromLatLngToContainerPixel(otherLoco.get("latlng"))
#           if Math.abs(thisPixelPosition.x - otherLocoPixelPosition.x) < 15 and Math.abs(thisPixelPosition.y - otherLocoPixelPosition.y) < 15
#             locomotives.push otherLoco

#         locomotives = _.sortBy(locomotives, (l) -> l.id)

#         @map.set("bounds", bounds.extend(latLong) )
#         marker = Cds.mapping.createLocoMapMarker( locomotive, map )
#         @map.get("markers").push( marker )
#         google.maps.event.addDomListener( marker, 'click', (ev) =>
#           Cds.mapping.openFullLocoMapInfoWindow( locomotives, map, marker, @user )
#         )
#         google.maps.event.addDomListener( marker, 'mouseover', (ev) =>
#           Cds.mapping.openLocoMapInfoWindow( locomotives, map, marker, @user )
#         )
#         google.maps.event.addDomListener( marker, 'mouseout', (ev) =>
#           Cds.mapping.closeLocoMapInfoWindow( locomotives, map, marker, @user )
#         )

#   addSeverityFilter: ->
#     self = @
#     severityEls =
#       """
#       <div class="severity-filter">
#         <select class="form-control">
#           <option value="Show All">Show All</option>
#           <option value="Critical">Critical</option>
#           <option value="Warning">Warning</option>
#           <option value="Message">Message</option>
#         </select>
#       </div>
#       """
#     @$(".summary-locomotive-filter-wrap").prepend(severityEls)
#     @$(".severity-filter option").each( () ->
#       if $(@).text() == self.prefSeverityFilter
#         $(@).parent("select").val($(@).text())
#     )

#   showDatePicker: (e) ->
#     $(e.target).parent().find(".datepicker-popup").fadeIn()
#     $datePicker = $(e.target).parent().find("#datepicker").fadeIn()
#     @addDatePickers($datePicker)

#   reportDatePicker: (e) ->
#     $(e.target).parent().find(".datepicker-popup").fadeIn()
#     $datePicker = $(e.target).parent().find("#datepicker").fadeIn()
#     @addDatePickers($datePicker)
#     if $('.severity-filter').length == 0
#       @addSeverityFilter()
#     else

#   addDatePickers: ($el) ->
#     self = @
#     chosenToggle = false
#     fromDate = moment()
#     toDate = moment()
#     chosenDates = Cds.time.getDateSelectionByDays(fromDate, toDate)
#     $el.datepicker(
#       numberOfMonths: 3
#       maxDate: '+0m +0w'
#       minDate: new Date(2013, 1 - 1, 1)
#       altFormat: "MM d, yy"
#       beforeShowDay: (date) ->
#         # disable dates before chosen from date, if one has been chosen
#         if chosenToggle is true
#           chosenFromDateUnix = fromDate.format("X")
#           calendarDateUnix = moment(date).format("X")
#           if chosenFromDateUnix > calendarDateUnix
#             return [false]
#         year = moment(date).format("YYYY") * 1
#         month = moment(date).format("M") * 1
#         day = moment(date).format("D") * 1
#         i = 0
#         # match chosen days to add highlightening
#         while i < chosenDates.length
#           return [true, "ui-state-chosen"] if year is chosenDates[i][0] and month is chosenDates[i][1] and day is chosenDates[i][2]
#           ++i
#         [true]
#       onSelect: (date, inst) ->
#         toDate =  moment(date)
#         if chosenToggle is false
#           fromDate =  moment(date)
#           chosenToggle = true
#         else
#           chosenToggle = false
#           self.resetDatePicker(@)
#           self.fetchFleetReport(fromDate, toDate)
#         chosenDates = Cds.time.getDateSelectionByDays(fromDate, toDate)
#         inst.settings.beforeShowDay(date)
#     )

#   resetDatePicker: (tgt) ->
#     $(tgt).parentsUntil(".date-picker-wrap").hide()
#     $(tgt).datepicker( "destroy" )


#   fetchFleetReport: (fromDate, toDate) ->
#     $modal = @$('#loadingFleetReportModal')
#     $modal.modal('show')
#     $modelContent = $modal.find(".modal-body")
#     $modelContent.html("<div class='modal-loading'>Fetching fleet report ...</div>")
#     fleetReport = $.ajax
#       type: "GET"
#       url: "/api/fleet_report"
#       data:
#         from: fromDate.format("YYYY-MM-DD")
#         to: toDate.format("YYYY-MM-DD")
#     fleetReport.fail (jqXHR, textStatus) ->
#       $modelContent.text("There was an error: #{jqXHR.status} #{jqXHR.statusText}")
#     fleetReport.done (msg) ->
#       filePath = msg.url
#       $modelContent.html("The file is ready. <a class='btn btn-default' href='#{filePath}'>Download File</a>")

# _.extend(Cds.Views.LocomotivesIndex.prototype, Cds.Mixins.UI)

# $ ->
#   $('body div:not(.reability-rpt)').on 'click', (event) ->
#     if $(event.target).parents('.ability-rpt-btn').length > 0
#       return
#     $('.datepicker-popup').hide()
