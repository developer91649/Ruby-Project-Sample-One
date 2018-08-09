class Cds.Collections.TargetAnalysisModes extends Backbone.Collection
  model: Cds.Models.TargetAnalysisMode

  parse: (resp, xhr) ->
    return resp