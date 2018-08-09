class Cds.Models.LocomotiveType extends Backbone.Model
  defaults:
    selected: false

  urlRoot: '/api/locomotive_types'

  initialize: (attributes, options) ->
    @locomotive_types = new Cds.Collections.LocomotiveTypes()
    _.bindAll(@)
