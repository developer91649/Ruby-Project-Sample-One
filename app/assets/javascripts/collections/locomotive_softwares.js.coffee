class Cds.Collections.LocomotiveSoftwares extends Backbone.Collection

  model: Cds.Models.LocomotiveSoftware

  initialize: () ->
    _.bindAll(@)

  parse: (resp, xhr) ->
    return resp

