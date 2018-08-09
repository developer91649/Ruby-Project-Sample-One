class Cds.Collections.SendFileFlags extends Backbone.Collection

  model: Cds.Models.SendFileFlag

  initialize: (models, options) ->

  url: ->
    @system.url() + "/system"

  parse: (resp, xhr) ->
    return resp
