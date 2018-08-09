class Cds.Collections.SystemStatuses extends Backbone.Collection

  model: Cds.Models.SystemStatus

  initialize: ->

  parse: (resp, xhr) ->
    return resp

  systemStatusTooltip: ->
    # some system dups now, but just throwing things in there
    tooltips =
      CDS:
        0: "CDS to web site communication temporarily interrupted."
        1: "CDS is communicating with the web site."
      PHW:
        Online: "The cab signal system is communicating with the CDS."
        Offline: "The cab signal system to CDS communication has been temporarily interrupted."
        "Cut-in": "The cab signal system is communicating with the CDS and the locomotive is in cab territory."
        "Cut-out": "The cab signal system is communicating with the CDS and the locomotive is in non-cab territory."
      GPS:
        0: "The GPS to CDS communication has been temporarily interrupted."
        1: "The GPS is communicating with the CDS."
      QES:
        0: "The QES to CDS communication has been temporarily interrupted."
        1: "The QES is communicating with the CDS."
      HEP:
        0: "The HEP to CDS communication has been temporarily interrupted."
        1: "The HEP is communicating with the CDS."
      HEP1:
        0: "The HEP to CDS communication has been temporarily interrupted."
        1: "The HEP is communicating with the CDS."
      HEP2:
        0: "The HEP to CDS communication has been temporarily interrupted."
        1: "The HEP is communicating with the CDS."
      PM:
        0: "No engine RPM detected."
        1: "Engine RPM detected."
      PM1:
        0: "No engine RPM detected."
        1: "Engine RPM detected."
      PM2:
        0: "No engine RPM detected."
        1: "Engine RPM detected."
      AESS:
        0: "QES engine start/stop control not active."
        1: "QES engine start/stop control enabled."