Cds.faults = do ->

  severityLevels =
    0:
      fault_status_class: "level_zero"
      fault_status_text: "Offline"
      fault_value: 4
      icon_image: "black_offline.png"
      color: "#999"
      opacity: .8
    1:
      fault_status_class: "level_one"
      fault_status_text: "Critical"
      fault_value: 1
      icon_image: "red_x.png"
      color: "red"
      opacity: .8
    2:
      fault_status_class: "level_two"
      fault_status_text: "Warning"
      fault_value: 2
      icon_image: "yellow_warning.png"
      color: "#ccc50e"
      opacity: .8
    3:
      fault_status_class: "level_three"
      fault_status_text: "Message"
      fault_value: 3
      icon_image: "green_check.png"
      color: "green"
      opacity: .8

  return {

    getSeverity: (severityLevelInt) ->
      severity = severityLevels[severityLevelInt] || severityLevels[3]
  }