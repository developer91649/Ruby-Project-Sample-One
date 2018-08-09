Cds.mapping = do ->
  infoWindow = undefined
  maxLocosInfoWindow = 4

  return {

    getLocoStatusGraphics: (status) ->
      Cds.locomotives.getCurrentSeverityGraphics(status)

    formatTime: (opts={}) ->
      Cds.time.getTimeByUserPref(opts)

    openLocoMapInfoWindow: (locos, map, marker, user) ->
      template = JST['maps/loco_infobox']
      _templ = template(
        locomotives: locos
        time: @formatTime
        user: user
        maxLocos: maxLocosInfoWindow
      )
      infoWindow = new InfoBox(
        content: _templ
        pixelOffset: new google.maps.Size(20, -50)
        boxClass: "loco-info"
        closeBoxMargin: "-9999px -9999px 0 0"
      )
      infoWindow.open map, marker

    closeLocoMapInfoWindow: (locos, map, marker) ->
      infoWindow.close map, marker

    openFullLocoMapInfoWindow: (locos, map, marker, user) ->
      template = JST['maps/loco_infobox_full']
      _templ = template(
        locomotives: locos
        time: @formatTime
        user: user
        maxLocos: maxLocosInfoWindow
      )
      fullInfoWindow = new InfoBox(
        content: _templ
        pixelOffset: new google.maps.Size(20, -50)
        boxClass: "loco-info"
        closeBoxMargin: "-10px -10px 0 0"
        closeBoxURL: "/assets/close-light-sm.png"
      )
      fullInfoWindow.open map, marker

      google.maps.event.addListener fullInfoWindow, "domready", =>
        $locoInfo = $(".loco-info-wrap")
        locoInfoHeight = 0
        $locoInfo.find(".loco-info-pack").each (i) ->
          return if i >= maxLocosInfoWindow
          locoInfoHeight += $(this).outerHeight()

        $locoInfo.css height: locoInfoHeight - 1

        $(".loco-info-scroll.up").on "click", (e) ->
          e.preventDefault()
          $locoInfo.animate scrollTop: "-=#{locoInfoHeight}"

        $(".loco-info-scroll.down").on "click", (e) ->
          e.preventDefault()
          $locoInfo.animate scrollTop: "+=#{locoInfoHeight}"

    # LOCOMOTIVE INFOBOX
    getLocoMapIcon: (fill, stroke = "black") ->
      locoSVG = "
        M0-0.536c-0.148,0-0.282,0.06-0.379,0.157S-0.536-0.148-0.536,0s0.06,0.282,
        0.157,0.379S-0.148,0.536,0,0.536s0.282-0.06,0.379-0.157S0.536,0.148,0.536,
        0s-0.06-0.282-0.157-0.379S0.148-0.536,0-0.536z

        M0-1.219c-0.673,0-1.219,0.546-1.219,1.219c0,0.673,0.546,1.219,1.219,
        1.219c0.673,0,1.219-0.546,1.219-1.219 C1.219-0.673,0.673-1.219,0-1.219z
        M0,1.078c-0.595,0-1.078-0.483-1.078-1.078c0-0.595,0.483-1.078,1.078-1.078
        c0.595,0,1.078,0.483,1.078,1.078C1.078,0.595,0.595,1.078,0,1.078z

        M0-0.879c-0.485,0-0.879,0.393-0.879,0.879S-0.485,0.879,0,0.879S0.879,
        0.485,0.879,0S0.485-0.879,0-0.879z M0,0.685 c-0.378,
        0-0.685-0.307-0.685-0.685c0-0.378,0.307-0.685,0.685-0.685c0.378,0,0.685,
        0.307,0.685,0.685 C0.685,0.378,0.378,0.685,0,0.685z"
      
      path: locoSVG
      fillColor: fill
      fillOpacity: 0.9
      strokeColor: stroke
      strokeOpacity: 0.4
      strokeWeight: 1
      scale: 16

    createLocoMapMarker: (model, map) ->
      icon = @getLocoMapIcon(model.get("color"))
      marker = new google.maps.Marker(
        position: new google.maps.LatLng(model.get("latitude"), model.get("longitude"))
        icon: icon
        loco: model
        map: map
      )
      model.set("marker", marker)
      return marker

    # FAULT INFOBOX
    openFaultMapInfoWindow: (locomotive, fault, map, marker, user) ->
      template = JST['maps/fault_infobox']
      _templ = template(
        locomotive: locomotive
        fault: fault
        time: @formatTime
        user: user
      )
      infoWindow = new InfoBox(
        boxStyle:
          width: "160px"
        content: _templ
        pixelOffset: new google.maps.Size(20, -50)
        boxClass: "loco-info fault-info"
        closeBoxMargin: "-10px -10px 0 0"
        closeBoxURL: "/assets/close-light-sm.png"
      )
      infoWindow.open map, marker

    createFaultMapMarker: (locomotive, map, fault) ->
      icon = @getLocoMapIcon(locomotive.get("color"))
      # override locomotive color with fault color
      severity = Cds.faults.getSeverity(fault.get("severity"))
      icon.fillColor = severity.color
      latlong = fault.get("gps").split(",")
      marker = new google.maps.Marker(
        position: new google.maps.LatLng(latlong[0], latlong[1])
        icon: icon
        loco: locomotive
        map: map
      )

    }