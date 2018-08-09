class Cds.Models.ParamChart extends Backbone.Model
  defaults:
    currentDateRange: {}
    inProcess: false
    started: false
    loading: false
    valid: undefined
    validation:
      locomotive_type:
        valid: false
        msg: "Please choose a locomotive type."
      locomotive:
        valid: false
        msg: "Please choose at least one locomotive."
      parameter:
        valid: false
        msg: "Please choose a parameter"
    maxX: 0
    minX: 0
    defaultThresholdOptions:
      type: 'line'
      lineWidth: 1
      data: []
      color: '#c80000'
      marker:
        enabled: false
      tooltip:
        enabled: false
      states:
        hover:
          lineWidth: 0
      enableMouseTracking: false

  initialize: () ->
    @get("locomotives").forEach( (loco) =>
      loco.on("change:paramInstances", @updateChartWithInstances, @)
    )

  removeSeries: (loco) ->
    chart = @get("chart")
    series = chart.series
    locoName = loco.get("title")
    _.each(series, (data, i) ->
      if data.name == locoName
        chart.series[i].remove(true)
    )
    chart.redraw()

  resetValidation: ->
    validation = @get("validation")
    _.each(validation, (required) ->
      required.valid = false
    )
    @set("validation", validation)

  validateOptions: ->
    @resetValidation()
    validation = @get("validation")

    currentParam = @get("parameters").getSelected()
    validation["parameter"].valid = true unless $.isEmptyObject(currentParam)

    currentLocos = @get("locomotives").selected
    validation["locomotive"].valid = true unless currentLocos.length < 1

    @set("validation", validation)

    if validation["locomotive"].valid is true and validation["parameter"].valid is true
      @set("valid", true, silent: true)
    else
      @set("valid", false, silent: true)
    @trigger("change:valid")
    return @get("valid")

  stopInProcess: ->
    @set("inProcess", false)

  startInProcess: ->
    @set("inProcess", true)

  updateChartWithInstances: (loco) ->
    if loco.get("paramInstances").length > 0
      @addLocoSeriesData(loco.get("paramInstances"), loco)

  matchDateOption: (id) ->
    dateOptions = Cds.charts.getDateOptions()
    _.find(dateOptions, (option) =>
      parseInt(option.hours) == parseInt(id)
    )

  drawChart: ->
    chart = @get("chart")
    if chart?
      chart.destroy()
    @set( "chart", new Highcharts.Chart( @get("chartOptions") ) )

  checkForExistingSeriesData: (locoName) ->
    dataExists = false
    series = @get("chartOptions").series
    _.each(series, (data) ->
      if data.name is locoName then dataExists = true
    )
    return dataExists

  addLocoSeriesData: (paramInstances, loco) ->
    locoName = paramInstances[0].locomotive_name
    seriesExists = @checkForExistingSeriesData(locoName)
    if seriesExists
      series = @get("chartOptions").series
      _.each(series, (data, i) ->
        if data.name == locoName
          series.splice(i, 1)
      )
      @get("chartOptions").series = series

    locoSeriesData =
      name: loco.get("title")
      locomotiveID: loco.get("id")
      hasCriticalAlarms: false
      data: []

    _.each(paramInstances, (instance, i) =>
      # return if i > 400
      instance.chartify()

      if instance.isCriticalAlarm() then locoSeriesData.hasCriticalAlarms = true

      # Initially disable the dataLabels to display on a marked point
      instance.dataLabels = { enabled: false }

      locoSeriesData.data.push(instance)
    )

    @get("chartOptions").series.push(locoSeriesData)

  setChartOptions: (chosenParam, options, monitoringView) ->
    @monitoringView = monitoringView
    self = @
    options = options ? {}
    Highcharts.setOptions(
      global:
        useUTC: true
    )
    chartOptions =
      units: chosenParam.get("units")
      chart:
        renderTo: 'chart-container'
        defaultSeriesType: 'line'
        marginRight: 20
        marginLeft: 80
        zoomType: 'xy'
        backgroundColor: null

        resetZoomButton:
          theme:
            display: 'none'
        events:
          load: ()->
            @selectedPointCount = 0
            $('#critical-toggle').removeClass "disabled"

      title:
        text: ""

      subtitle:
        text: ""

      colors: [
        '#2f7ed8',
        '#8bbc21',
        '#910000',
        '#1aadce',
        '#492970',
        '#f28f43',
        '#77a1e5',
        '#c42525',
        '#a6c96a',
        '#f26d7d'
      ]

      credits:
        enabled: false

      xAxis:
        type: 'datetime'
        labels:
          enabled: true
          align: 'center'
        maxZoom: 60 * 1000
        events:
          afterSetExtremes: (e)->
            if e.dataMin < e.userMin || e.dataMax > e.userMax
              $("#reset-zoom").removeClass "disabled"

      yAxis:
        title:
          text: chosenParam.get("units")
        max: chosenParam.get("chart_max") || options.chart_max
        min: chosenParam.get("chart_min") || options.chart_min
        allowDecimals:
          false
        minTickInterval:
          1

      plotOptions:
        line:
          lineWidth: 1
          shadow: false
          states:
            hover:
              lineWidth: 1
          marker:
            enabled: true
            fillColor: null
            lineColor: null
            radius: 0
            symbol: "circle"
            states:
              hover:
                enabled: true
                radius: 4
                symbol: "circle"
              select:
                enabled: true
                symbol: "circle"
        series:
          cursor: 'pointer'
          turboThreshold: 0
          dataLabels:
            align: "center"
            verticalAlign: "middle"
            enabled: true # Must be enabled here, as HC will not dynamically enable per-point
            borderRadius: 3
          events:
            click: (event) => @monitoringView.openModes(event.point)
      tooltip:
        animation: false
        hideDelay: 0
        useHTML: true
        formatter: () ->
          html = "<b>#{@series.name}</b><br/>#{Highcharts.dateFormat('%Y-%m-%e %H:%M:%S', @x)} UTC<br/><b>Value: #{@y} #{@series.chart.userOptions.units}</b>"
          html += "<div class='critical-alarm-notification'>Critical Alarm <small>Click for Details</small></div>" if @point.isCriticalAlarm()
          return html

      series: []

    # set extra yAxis for status - set in locomotive_router
    if options.yAxisOptions?
      if options.yAxisOptions.tickInterval?
        chartOptions.yAxis.tickInterval = options.yAxisOptions.tickInterval
      if options.yAxisOptions.gridLineWidth?
        chartOptions.yAxis.gridLineWidth = options.yAxisOptions.gridLineWidth
      if options.yAxisOptions.minorGridLineWidth?
        chartOptions.yAxis.minorGridLineWidth = options.yAxisOptions.minorGridLineWidth
      if options.yAxisOptions.endOnTick?
        chartOptions.yAxis.endOnTick = options.yAxisOptions.endOnTick
      if options.yAxisOptions.startOnTick?
        chartOptions.yAxis.startOnTick = options.yAxisOptions.startOnTick
      if options.yAxisOptions.categories?
        chartOptions.yAxis.categories = options.yAxisOptions.categories

    @set("chartOptions", chartOptions)
    return chartOptions

  setxAxisFormat: (dateRangeModel) ->
    chartOptions     = @get("chartOptions")
    chosenDateRange  = dateRangeModel.currentDateRange
    to               = chosenDateRange.get("from_date_raw")
    from             = chosenDateRange.get("to_date_raw")
    dateRangeInHours = moment(from).diff(to, "hours")

    if dateRangeInHours < 72
      chartOptions.xAxis.tickInterval = 2 * 60 * 60 * 1000 #every other hour
      chartOptions.xAxis.dateTimeLabelFormats = { hour: '%H:%M' }
    else if dateRangeInHours < 360
      chartOptions.xAxis.tickInterval = 24 * 60 * 60 * 1000 #daily
      chartOptions.xAxis.dateTimeLabelFormats = { day: '%b %e' }
    else if dateRangeInHours < 2160
      chartOptions.xAxis.tickInterval = 7 * 24 * 60 * 60 * 1000 #weekly
      chartOptions.xAxis.dateTimeLabelFormats = { week: '%b %e' }
    else
      chartOptions.xAxis.tickInterval = 4 * 7 * 24 * 60 * 60 * 1000 #monthly
      chartOptions.xAxis.dateTimeLabelFormats = {  month: '%b %e' }

  addThresholds: ->
    chartOptions = @get("chartOptions")
    defaultThresholdOptions = @get("defaultThresholdOptions")
    chosenParam = @get("parameters").selected
    minX = @get("minX")
    maxX = @get("maxX")
    if chosenParam.get("threshold_max")?
      thresholdOptionsMax = _.clone(defaultThresholdOptions)
      thresholdOptionsMax.name = "Max"
      thresholdOptionsMax.data = [[minX, chosenParam.get("threshold_max")], [maxX, chosenParam.get("threshold_max")]]
      chartOptions.series.push(thresholdOptionsMax)

    if chosenParam.get("threshold_min")?
      thresholdOptionsMin = _.clone(defaultThresholdOptions)
      thresholdOptionsMin.name = "Min"
      thresholdOptionsMin.data = [[minX, chosenParam.get("threshold_min")], [maxX, chosenParam.get("threshold_min")]]
      chartOptions.series.push(thresholdOptionsMin)
    
  setMinX: (time) ->
    currentMinX = @get("minX")
    if currentMinX == 0 or time < currentMinX
      @set("minX", time)

  setMaxX: (time) ->
    currentMaxX = @get("maxX")
    if currentMaxX == 0 or time > currentMaxX
      @set("maxX", time)
