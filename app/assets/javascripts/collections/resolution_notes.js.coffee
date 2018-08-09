class Cds.Collections.ResolutionNotes extends Backbone.Collection
  url: '/resolution_notes'
  model: Cds.Models.ResolutionNote

  parse: (resp, xhr) ->
    return resp
