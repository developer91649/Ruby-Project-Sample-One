class Cds.Collections.LocomotiveDatas extends Backbone.Collection

  model: Cds.Models.LocomotiveData

  initialize: () ->
    _.bindAll(@)

  parse: (resp, xhr) ->
    return resp

