class Cds.Collections.FuelHistories extends Backbone.Collection

  model: Cds.Models.FuelHistory

  initialize: () ->
    _.bindAll(@)

  parse: (resp, xhr) ->
    return resp

