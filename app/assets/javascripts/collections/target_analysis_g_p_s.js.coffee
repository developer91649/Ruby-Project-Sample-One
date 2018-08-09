class Cds.Collections.TargetAnalysisGPS extends Backbone.Collection
  model: Cds.Models.GPS

  parse: (resp, xhr) ->
    return resp