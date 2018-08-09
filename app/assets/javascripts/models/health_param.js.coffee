class Cds.Models.HealthParam extends Backbone.Model
  defaults:
    selected: false

  initialize: () ->
    @healthparams = new Cds.Collections.HealthParams()
    @saveCategoryValue()
    @splitGPS()

  saveCategoryValue: ->
    if @get("category")?
      @set("categoryValue" , @get("category").toLowerCase().replace(" ", "_"))

  splitGPS: ->
    if @get("gps")?
      gpsString = @get("gps").split ","
      @set("lat", gpsString[0])
      @set("lng", gpsString[1])

  setSelectedParam: () ->
    @collection.setSelected(@)

  removeSelectedParam: () ->
    @collection.removeSelected(@)

  getGPSCoords: ->
    lat: parseFloat(@get("lat"))
    lng: parseFloat(@get("lng"))

  isCriticalAlarm: ->
    @get("qes_sequence") == 0

  epochTime: ->
    moment.utc(@get("time_utc")).valueOf()

  chartify: ->
    @x = @epochTime()
    @y = @get("value")

  getModes: ->
    modes = []
    _.each(@attributes, (value, attr) ->
      attrName = "#{value}"
      if attr.indexOf("mode_") isnt -1
        modes.push(attr)
    )
    return modes
