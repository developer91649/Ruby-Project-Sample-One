class Cds.Collections.LocomotiveEngineDatas extends Backbone.Collection

  model: Cds.Models.LocomotiveEngineData

  initialize: () ->
    _.bindAll(@)

  parse: (resp, xhr) ->
    return resp

