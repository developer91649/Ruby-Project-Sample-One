Cds.targetAnalysis = do ->
  # ["mode_brake", "mode_fuel", "mode_gps", "mode_loading", "mode_power", "mode_subsystem", "mode_wide"]
  modes =
    mode_power:
      title: "Power Mode"
      class: "target"
      position: 1
    mode_brake:
      title: "Blended Brake Mode"
      class: "target"
      position: 2
    mode_fuel:
      title: "Fuel Mode"
      class: "target"
      position: 3
    mode_loading:
      title: "Loading History"
      class: "loading-history"
      position: 4
    mode_subsystem:
      title: "Subsystem History"
      class: "history"
      position: 5
    mode_wide:
      title: "Wide"
      class: "target"
      position: 6

  return {
    # array of mode values from param
    matchModes: (modeValues) ->
      modeTitles = modes
      matchedModes = []
      _.each modeValues, (modeValue) ->
        _.find modeTitles, (mode, value) ->
          if value is modeValue
            mode.value = value
            matchedModes.push(mode)
      matchedModes = _.sortBy(matchedModes, (mode) -> mode.position )
      return matchedModes

    getModes: ->
      return modes

  }
