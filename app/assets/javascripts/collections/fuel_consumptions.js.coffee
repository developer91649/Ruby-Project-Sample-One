class Cds.Collections.FuelConsumptions extends Backbone.Collection

  model: Cds.Models.FuelConsumption

  initialize: () ->
    _.bindAll(@)

  parse: (resp, xhr) ->
    return resp

