class Cds.Views.Map extends Backbone.View
  template: JST['gps/map']
  className: 'map-container'

  events:
    'click #locomotive-detail-nav button': 'navigateInQuickview'

  render: (width, height)->
    mapOptions = $.extend(
      center: 
        lat: 0
        lng: 0
      zoom: 18
      width: '540px'
      height: '730px'
      streetViewControl: false
      mapTypeId: google.maps.MapTypeId.SATELLITE
    , @options)

    @map = new google.maps.Map @$el.get(0), mapOptions
    google.maps.event.trigger @map, 'resize'


  center: (map) ->
    google.maps.event.trigger( @map.get("map"), 'resize' )
    @map.get("map").setCenter( @map.get("marker").getPosition() )