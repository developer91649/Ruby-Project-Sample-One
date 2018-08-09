class Cds.Models.GPS extends Backbone.Model

  initialize: () ->

  getGPSCoords: ->
    lat: parseFloat(@get("latitude"))
    lng: parseFloat(@get("longitude"))

  # parse: (response)->