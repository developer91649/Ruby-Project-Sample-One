class Cds.Models.Map extends Backbone.Model
  defaults:
    currentGps: new google.maps.LatLng()
    map: ""
    mapOptions: {}
    marker: {}
    markers: []
    bounds: new google.maps.LatLngBounds()
    mapOptions: {}

