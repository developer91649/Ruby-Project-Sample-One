class Cds.Collections.TargetAnalysisParams extends Backbone.Collection

  model: Cds.Models.TargetAnalysisParam

  parse: (response)->

    # Not knowing what values are actually boolean by the data, and knowing that
    # the client was expecting to see boolean values displayed without units
    # I have opted to just make the adjustment at this stage.
    #
    # @todo: Abstract this

    _.map response.data, (data) ->
      if (data.units in [
        "on/off",
        "Forward",
        "Reverse",
        "Slip",
        "Run",
        "Sand"
      ])
        data.value = (if data.value then "On" else "Off")
        data.units = ""

      if data.units == "Active/Not-Active"
        data.value = (if data.value then "Active" else "Not-Active")
        data.units = ""

      data