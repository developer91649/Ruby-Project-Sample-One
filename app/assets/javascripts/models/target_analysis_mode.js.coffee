class Cds.Models.TargetAnalysisMode extends Backbone.Model
  defaults:
    title: ""
    value: ""

  initialize: () ->
    _.bindAll(@)

    @set("shortName", @get("value").replace("mode_", ""))

  parse: (data) ->
    return data