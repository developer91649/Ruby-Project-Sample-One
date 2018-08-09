class Cds.Collections.LocomotiveTypes extends Backbone.Collection
  url: '/api/locomotive_types'
  model: Cds.Models.LocomotiveType

  initialize: () ->
    @selected = -1
    _.bindAll(@)

  getSelected: () ->
    @selected

  setSelected: (id) ->
    @selected = id     
    