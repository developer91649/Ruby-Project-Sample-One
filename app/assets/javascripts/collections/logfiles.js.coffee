class Cds.Collections.Logfiles extends Backbone.Collection

  model: Cds.Models.Logfile

  initialize: (models, options) ->
  
  url: ->
    @system.url() + "/system"

  parse: (resp, xhr) ->
    return resp
