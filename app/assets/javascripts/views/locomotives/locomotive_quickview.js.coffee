class Cds.Views.LocomotiveQuickview extends Backbone.View
  template: JST['locomotives/locomotive_quickview']

  events:
    'click #toggle-quickview': 'toggleMap'
    'click #loco-subnav-toggle': 'toggleSubNav'
    # 'click #locomotive-detail-nav button': 'navigateInQuickview'

  initialize: ->
    _.bindAll(@)
    @user = @options.user
    @locomotive_list = ''
    @model.locomotives.fetch(
      success: (response) =>
        @locomotive_list = response
        @addTempNavigation()
    )
    @model.addStatusGraphics()
    @model.setCurrentLocoStatus()
    @startLocoLongPoll(
      interval: .2
    )
    _.bindAll(@)

  render: ->
    $(@el).html(@template(locomotive: @model))
    @appendMap()
    # @appendDetails(@model)
    _.defer( () =>
      @addActiveNav()
      @centerMap()
      @addQuickviewTextBtn()
    , this)
    this

  startLocoLongPoll: (opts={}) ->
    if opts.interval? then interval = 1000 * 60 * opts.interval else interval = 300
    pollOptions =
      delay: interval
    poller = Backbone.Poller.get(@model, pollOptions)
    poller.on('success', (model) =>
      $(".refresh-locomotive").fadeIn()
      @appendDetails(model)
      @moveMarker(model)
      $(".refresh-locomotive").fadeOut()
    )
    poller.start()

  addQuickviewTextBtn: ->
    # helper function to add text to button
#    if $("#quickview-wrap").is(":visible")
#      @$("#toggle-quickview").text('Hide -')
#    else
#      @$("#toggle-quickview").html('Show +')

  appendDetails: ->
    quickviewDetails = new Cds.Views.LocomotiveQuickviewDetails(
      model: @model
      user: @options.user
    )
    @$('.locomotive-quickview-details').empty().append(quickviewDetails.render().el)

  centerMap: (map) ->
    google.maps.event.trigger( @map.get("map"), 'resize' )
    @map.get("map").setCenter( @map.get("marker").getPosition() )

  appendMap: ->
    gps = @model.get("gps")
    if gps is null
      gps = "0.0,0.0"
    gps = gps.split(",")
    currentGps = new google.maps.LatLng(gps[0], gps[1])
    @map = new Cds.Models.Map(
      mapOptions:
        zoom: 18
        width: '540px'
        height: '370px'
        # draggable: false
        streetViewControl: false
        center: currentGps
        mapTypeId: google.maps.MapTypeId.SATELLITE
    )
    map = new google.maps.Map( @$("#locomotive-map-canvas")[0], @map.get("mapOptions") )
    @map.set( "currentGps", currentGps )
    @map.set( "map", map )
    marker = Cds.mapping.createLocoMapMarker(@model, map)
    @map.set( "marker", marker )
    google.maps.event.addDomListener( marker, 'mouseover', (ev) =>
      Cds.mapping.openLocoMapInfoWindow( [@model], map, marker, @user )
    )
    google.maps.event.addDomListener( marker, 'mouseout', (ev) =>
      Cds.mapping.closeLocoMapInfoWindow( [@model], map, marker, @user )
    )

  moveMarker: (loco) ->
    gps = @model.get("gps")
    if gps is null
      gps = "0.0,0.0"
    gps = gps.split(",")
    newGps = new google.maps.LatLng(gps[0], gps[1])
    @map.get("marker").setPosition(newGps)
    @map.get("map").panTo( newGps )

  addActive: (page) ->
    $(@el).find("#locomotive-detail-nav li").removeClass("active")
    sel_li_tag = $(@el).find("#locomotive-detail-nav a[data-link='#{page}']").parent()
    sel_li_tag.addClass("active")
    if sel_li_tag.hasClass("sub-menu")
      parent_id = sel_li_tag.attr("data-link")
      $(@el).find("#locomotive-detail-nav a[data-link='#{parent_id}']").parent().addClass("parent")

  addActiveNav: () ->
    location = @getLocation()
    @addActive(location.urlSegment)

  getLocation: () ->
    urlLocation = document.URL
    urlLocationSplit = urlLocation.split("/")
    if urlLocationSplit[5]
      lastUrlSegment = urlLocationSplit[5]
    if !lastUrlSegment?
      lastUrlSegment = "locomotive-detail"
    page = lastUrlSegment
    if page == "locomotive-detail"
      page = ""
    else
      page = "/#{page}"
    location =
      page: page
      urlSegment: lastUrlSegment

  navigateInQuickview: (e) ->
    $button = $(e.target)
    if $(e.target).is("span")
      $button = $button.parent("button")
    page = $button.attr("data-link")
    location = page
    if page == "locomotive-detail"
      page = ""
    else
      page = "/#{page}"
    Backbone.history.navigate("locomotives/#{@model.get('id')}#{page}", true)
    @addActive(location)

  addTempNavigation: () ->
    $(".locomotive-quickview-details-wrap .temp-navigation ul").empty();

    @locomotive_list.each((loco) ->
      $(".locomotive-quickview-details-wrap .temp-navigation ul").append('<li class="list-group-item"><a href="/locomotives/' + loco.get('id') + '" class="' + loco.get('id') + '"><span class="glyphicon glyphicon-ok"></span>' + loco.get('title') + '</a></li>');
    );
    $(".locomotive-quickview-details-wrap .temp-navigation ul li>a[class='" + @model.get('id') + "']").parent().addClass("active");
    this
  toggleSubNav: () ->
    $modal = $('#loco-subnav-modal')
    $modal.modal('show')

_.extend(Cds.Views.LocomotiveQuickview.prototype, Cds.Mixins.UI)

