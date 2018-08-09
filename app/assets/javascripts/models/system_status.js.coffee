class Cds.Models.SystemStatus extends Backbone.Model

  initialize: () ->
    @systems = new Cds.Collections.SystemStatuses()
    @getToolTipText()
    _.bindAll(this)

  getToolTipText: ->
    tooltipTextForAllStatuses = @systems.systemStatusTooltip()
    @set( systemStatusTooltipText: tooltipTextForAllStatuses[@get("system_name")][@get("system_status")] )

  getSystemStatusText: (account_id) ->
    # different per account
    statusConfig =
      1:
        GPS:
          0: "Offline"
          1: "Online"
        CDS:
          0: "Offline"
          1: "Online"
        QES:
          0: "Offline"
          1: "Online"
        PM1:
          0: "Stopped"
          1: "Running"
        AESS:
          0: "Disabled"
          1: "Enabled"
      5:
        GPS:
          0: "Offline"
          1: "Online"
        CDS:
          0: "Offline"
          1: "Online"
        QES:
          0: "Offline"
          1: "Online"
        PM1:
          0: "Stopped"
          1: "Running"
        AESS:
          0: "Disabled"
          1: "Enabled"
      4:
        CDS:
          0: "Offline"
          1: "Online"
        GPS:
          0: "Offline"
          1: "Online"
        QES:
          0: "Offline"
          1: "Online"
        HEP1:
          0: "Offline"
          1: "Online"
        HEP2:
          0: "Offline"
          1: "Online"
        PM1:
          0: "Stopped"
          1: "Running"
        PM2:
          0: "Stopped"
          1: "Running"
        AESS:
          0: "Disabled"
          1: "Enabled"

    status = @get("system_status")
    systemName = @get("system_name")
    if statusConfig[account_id]? and statusConfig[account_id][systemName]?
      statusText = statusConfig[account_id][systemName][status]
      @set(systemStatusText: statusText)