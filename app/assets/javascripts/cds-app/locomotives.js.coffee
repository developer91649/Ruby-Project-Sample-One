Cds.locomotives = do ->

  currentSeverity =
    0:
      loco_status_class: "level_four"
      loco_status_text: "Offline"
      loco_status_desc: "CDS communication temporarily interrupted."
      sort_value: 10
      graphics:
        icon_image: "black_offline.png"
        color: "#999"
        dark_color: "#999"
        opacity: .8
        locomotive_image: "locomotive-red.svg"
    1:
      loco_status_class: "level_one"
      loco_status_text: "Critical"
      loco_status_desc: "A locomotive fault has occurred that will cause train delay if not cleared."
      sort_value: 1
      graphics:
        icon_image: "red_x.png"
        color: "red"
        dark_color: "red"
        opacity: .8
        locomotive_image: "locomotive-red.svg"
    2:
      loco_status_class: "level_two"
      loco_status_text: "Warning"
      loco_status_desc: "A locomotive fault has occurred that may cause train delay if not cleared."
      sort_value: 2
      graphics:
        icon_image: "yellow_warning.png"
        color: "#ccc50e"
        dark_color: "#ab6a03"
        opacity: .8
        locomotive_image: "locomotive-yellow.svg"
    3:
      loco_status_class: "level_three"
      loco_status_text: "Message"
      loco_status_desc: "All systems functioning normally."
      sort_value: 3
      graphics:
        icon_image: "green_check.png"
        color: "green"
        dark_color: "green"
        opacity: .8
        locomotive_image: "locomotive-green.svg"
    4:
      loco_status_class: "level_zero"
      loco_status_text: "Comm Interrupted"
      loco_status_desc: "The GPS location updates temporarily interrupted. This may mean CDS is not communicating with the web site at all."
      sort_value: 4
      graphics:
        icon_image: "red_question.png"
        color: "red"
        dark_color: "red"
        opacity: .8
        locomotive_image: "locomotive-red.svg"
    5:
      loco_status_class: "level_three"
      loco_status_text: "No Alarms"
      loco_status_desc: "All systems functioning normally"
      sort_value: 5
      graphics:
        icon_image: "green_check.png"
        color: "green"
        dark_color: "green"
        opacity: .8
        locomotive_image: "locomotive-green.svg"
    6:
      loco_status_class: "level_out-of-service"
      loco_status_text: "Out of Service"
      loco_status_desc: "Locomotive is out of service"
      sort_value: 6
      graphics:
        icon_image: ""
        color: ""
        dark_color: ""
        opacity: .8
        locomotive_image: ""


  return {

    getCurrentSeverity: (severityLevelInt) ->
      severity = currentSeverity[severityLevelInt] || currentSeverity[5]

    getCurrentSeverityGraphics: (severityLevelInt) ->
      severity = currentSeverity[severityLevelInt] || currentSeverity[5]
      severity.graphics
  }
