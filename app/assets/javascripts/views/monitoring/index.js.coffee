# View events
# change parameter  -> fetch all locos
# add loco          -> fetch one new loco
# remove loco       -> remove one series of loco data
# change date range -> fetch all locos
class Cds.Views.MonitoringIndex extends Backbone.View
  xhrs: []
  template: JST["monitoring/index"]
  className: "monitoring-index"
  events:
    "click .loco-selected li": "removeLoco"
    "click .datepicker-popup form button": "initChart"
    "click .param-dropdown li": "chooseParam"
    "click .date-options a": "changeDateRange"
    "click .choose-param-btn": "paramDisplayToggle"
    "click .all-locos-display-toggle": "allLocosDisplayToggle"
    "click #export-csv": "ExportCsv"
    # "hide.bs.dropdown select.show-tick": "alert"
    "change #loco-type-select": "changeLocoTypeSelect"
    "click #confirm-loco-type-modal .confirm-change": "confirmChangeLocoType"
    "click #confirm-loco-type-modal .cancel-change": "cancelChangeLocoType"

  initialize: ->
    @user = @options.user
    @all_locomotives = @collection
    @locomotives = new Cds.Collections.Locomotives
    @locomotive_types = @options.locomotive_types
    @all_parameters = @options.parameters
    @chart_type_text = @options.chart_type_text
    @paramChart = @options.paramChart
    @paramChart.on("change:started", @startChartDisplay, @)
    @paramChart.on("change:loading", @toggleLoadDisplay, @)
    @paramChart.on("change:valid", @updateDisplayAfterValid, @)
    @all_parameters.on("change:selected", @updateParamDisplay, @)
    @selected = -1
    @chartColors = [
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

  render: ->
    if ($(window).width() > 480 or $('html.force-desktop').length > 0) and $('html.force-mobile').length is 0
      $(@el).html(@template(
        chart_type_text: @chart_type_text,
        locomotive_types: @locomotive_types,
        user: @user
      ))
      @$('.selectpicker').selectpicker()
      @$('.param-list-choices a').addClass('disabled')
      @saveDOMVars()
      @appendParameters()
      @renderLocomotives()
      @updateLocoType(@locomotive_types.getSelected())

      _.defer( () =>
        @dateOptions = Cds.charts.getDateOptions()
        @dateRangeSelector = new Cds.Views.DateRangeSelector(
          dateOptions: @dateOptions
          range: true
          time: false
        )

        @dateRangeSelector.currentDateRange.on("change:from_display", @updateFromDisplay)
        @dateRangeSelector.currentDateRange.on("change:to_display", @updateToDisplay)
        @dateRangeSelector.currentDateRange.on("change:from_date_raw", @initChart, @)

        $("#date-range-selector").replaceWith(@dateRangeSelector.render().$el)
        @dateRangeSelector.$buttonGroup.addClass "btn-group-sm"

        @$(".date-options a:first").trigger('click')
        @selectDefaultParam()
        @selectLocomotiveFromURL()
        $(".param-dropdown").columnize({ columns: 3 })
        paramChart = @paramChart

        @$(".chart-actions").on("click", "#reset-zoom", (e)->
          e.preventDefault()

          paramChart.get("chart").zoomOut()
          $(@).addClass "disabled"
        )

      , this)
    else
      $(@el).html("Graphs are unavailable in mobile screen mode.")
    @

  closeParamDropdown: () ->
    $('.param-list-choices').removeClass('open')

  changeLocoTypeSelect: () ->
    $paramContainer = $(".param-dropdown")
    categories = @all_parameters.getCategories()
    
    loco_type_id = $('#loco-type-select').val()
    $('#confirm-loco-type-modal').data('value', loco_type_id)
    
    if @locomotive_types.getSelected() == -1
      @confirmChangeLocoType()
    else if $(".loco-selected ul li").length == 0
      @confirmChangeLocoType()
    else if @locomotive_types.getSelected() != loco_type_id
      $('#confirm-loco-type-modal').modal('show')
    
    $paramContainer.find("li").addClass('hidden')
    @all_parameters.each( (param) ->
      if param.get("locomotive_type_id") == parseInt(loco_type_id)
        $paramContainer.find("li[data-id='#{param.get("id")}']").removeClass('hidden')
    )
    

  cancelChangeLocoType: () ->
    $('#loco-type-select').selectpicker('val', @locomotive_types.getSelected())

  confirmChangeLocoType: () ->
    $('#confirm-loco-type-modal').modal('hide')
    loco_type_id = $('#confirm-loco-type-modal').data('value')
    unless @locomotive_types.getSelected() == -1
      @removeAllSelectedLoco()
      @refreshParam()
    @locomotives.set(@all_locomotives.where(
      locomotive_type_id: parseInt(loco_type_id)
    ))

    $("#monitoring-locomotive-list-js li").addClass('disabled')
    @locomotives.forEach((e) =>
      $("#monitoring-locomotive-list-js li[data-id=#{e.get('id')}]").removeClass('disabled')
    )
    @locomotive_types.setSelected(loco_type_id)
    
  saveDOMVars: () ->
    @$loader          = @$(".chart-loader")
    @$chatWrapper     = @$(".chart-container-wrap")
    @$errorWrap       = @$(".errors-options")
    @$chartActions    = @$(".chart-actions")
    @$errorList       = @$errorWrap.find("ul")

  updateParamDisplay: (param) ->
    id = param.get("id")
    $paramDesc = @$(".param-description")
    @$("h3.param-chosen").text("#{param.get("title")}")
    @$(".param-list-choices").removeClass("open")
    $paramDesc.empty()
    if param.get("description")
      $paramDesc.html( param.get("description") )
    $(".param-dropdown li").removeClass("selected")
    $(".param-dropdown li[data-id='#{id}']").addClass("selected")

  selectLocomotiveFromURL: () ->
    if @options.urlSelected.locomotiveID?
      loco = @locomotives.get(@options.urlSelected.locomotiveID * 1)
      loco.setSelectedLoco()
      @initChart()

  updatePredefinedDateSelection: () ->
    $(".date-options a")
      .removeClass("active")
      .closest("[data-id='#{@get("id")}']")
      .addClass("active")

  updateFromDisplay: () ->
    display_time = @get("from_display")
    $(".date-range-display .chosen-from-date").text(display_time)
    $("#from").val(display_time)

  updateToDisplay: () ->
    display_time = @get("to_display")
    $(".date-range-display .chosen-to-date").text(display_time)
    $("#to").val(display_time)

  updateLocoType: (id) ->
    @removeAllSelectedLoco()
    @locomotive_types.setSelected(id)
    @locomotives.set(@all_locomotives.where(
      locomotive_type_id: @locomotive_types.getSelected()
    ))

  paramDisplayToggle: (e)->
    $btn = $('.choose-param-btn')
    top = $btn.position().top + $btn.outerHeight()
    @$(".param-list-choices").toggleClass("open")
    @$(".param-dropdown").css(top: top)
    
    
  allLocosDisplayToggle: ->
    @$("#monitoring-locomotive-list-js").slideToggle()

  datePickerDisplayToggle: ->
    @$(".date-options a:last").trigger('click')

  renderLocomotives: ->
    @all_locomotives.forEach( (model) =>
      model.on("change:paramInstances", @updateLocoDisplayForInstances, @)
      locomotiveView =  new Cds.Views.MonitoringLocomotive(
        model: model
        all_locomotives: @locomotives
        chartView: @
        paramChart: @paramChart
      )
      @$("#monitoring-locomotive-list-js").append(locomotiveView.render().el)
    )

  selectDefaultParam: ->
    # either default param in url or to user's pref
    if @options.urlSelected.param?
      defalocomotiveslocomotivesultParam = @all_parameters.find( (param) =>
        return @options.urlSelected.param == param.get("qes_variable")
      )
      defaultParam.setSelectedParam()
      @initChart()
    else
      type = "#{@options.chart_type_text}".toLowerCase()
      defaultParamID = @options.user.get("pref_default_#{type}_param") * 1
      if defaultParamID isnt 0
        defaultParam = @all_parameters.get(defaultParamID)
        if defaultParam?
          defaultParam.setSelectedParam()
          @initChart()

  appendParameters: ->
    self = @
    $paramContainer = @$(".param-dropdown")

    getCategoryDOM = (categories) ->
      categoryDOM = ""
      _.each(categories, (category) ->
        template = JST['monitoring/param_category']
        categoryDOM += template(category)
      )
      categoryDOM

    categories = @all_parameters.getCategories()
    if categories.length > 0
      $paramContainer.prepend( getCategoryDOM(categories) )
      @all_parameters.each( (param) ->
        if param.get("category")
          $paramContainer.find("ul[data-category='#{param.get("categoryValue")}']").append(
            new Cds.Views.ParamOption( model: param, paramChart: self.options.paramChart ).render().el
          )
      )
    else
      $paramContainer.append("<ul class='no-category'></ul>")
      $paramList = $paramContainer.find("ul")
      @all_parameters.each( (param) ->
        $paramList.append( new Cds.Views.ParamOption( model: param, paramChart: self.options.paramChart ).render().el )
      )

  removeAllSelectedLoco: (e) ->
    $(@el).find('.loco-selected li').remove()
    @locomotives.forEach( (loco) =>
      @removeSelectedLoco(loco.get('id'))
    )

  removeSelectedLoco: (id) ->
    locoToRemove = @all_locomotives.find (loco) ->
      return loco if loco.get("id") is id
    @xhrs[id].abort() if @xhrs[id]?

    locoToRemove.removeSelectedLoco()

    $("#monitoring-locomotive-list-js li[data-id='#{id}']").removeClass("selected")

    isValidated = @paramChart.validateOptions()
    @paramChart.set("loading", true)
    paramInstances = locoToRemove.get("paramInstances")
    # remove series from chart and redraw chart
    # or remove from no data list
    if paramInstances.length > 0
      @paramChart.removeSeries(locoToRemove)
    else
      @removeLocoFromNoData(locoToRemove)
    @paramChart.set("loading", false)

  # the view and data concerns should be split out
  removeLoco: (e) ->
    $tgt = $(e.currentTarget)
    id = parseInt $tgt.attr("data-id")
    $tgt.tooltip("destroy")
    $tgt.remove()
    @removeSelectedLoco(id)
    
    param_id = $('.param-dropdown li.selected').attr("data-id")
    removeParam = @all_parameters.find( (param) =>
      param.id == param_id * 1
    )
    if $(".loco-selected ul li").length == 0
      if removeParam != undefined
        removeParam.removeSelectedParam()
      @refreshParam()
      $('.param-dropdown li').removeClass('selected')
  refreshParam: ->
    $(".param-list-choices .param-chosen").text("SELECT A #{@chart_type_text} PARAMETER.")

  removeLocoFromNoData: (loco) ->
    $(".loco-selected li[data-id=#{loco.get('id')}]")
      .removeClass('no-data')
      .tooltip("destroy")
      
  chooseParam: (e) ->
    id = $(e.target).attr("data-id")
    chosenParam = @all_parameters.find( (param) =>
      param.id == id * 1
    )
    chosenParam.setSelectedParam()
    @initChart()

  addLocoSelectedColors: (chart) ->
    colors = chart.options.colors
    $(".loco-selected li").each( (i) ->
      domName = $(@).data("name")
      loco = _.find(chart.series, (line) ->
        name = line.name.replace("Loco: ", "")
        domName == name
      )
      if loco?
        $(@).css("background-color", loco.color).tooltip("destroy").removeClass("no-data")
    )

  clearXHRs: () ->
    if @xhrs.length > 0
      _.each(@xhrs, (xhr) ->
        xhr.abort()
      )
      @xhrs = []

  finishChart: () ->
    # only when date has changed
    @paramChart.setxAxisFormat(@dateRangeSelector)
    # only when parameter has changed - needs to happen after param data is loaded
    @paramChart.addThresholds()
    @paramChart.drawChart()
    @paramChart.stopInProcess()
    # only when loco added - needs to happen after chart is loaded
    @addLocoSelectedColors(@paramChart.get("chart"))
    @paramChart.set("started", false)
    @paramChart.set("loading", false)

  processChartData: (paramCollection) ->
    loco = paramCollection.locomotive
    loco.set("paramInstances", paramCollection.models, silent: true)
    loco.trigger('change:paramInstances', loco)

  # update loco display when param data is loaded
  updateLocoDisplayForInstances: (loco) ->
    paramInstances = loco.get("paramInstances")
    if paramInstances.length == 0
      $(".loco-selected li[data-id='#{loco.get("id")}']").addClass("no-data").tooltip(
        title: "There is no data for the chosen parameter/date range"
      )
      .css("background-color", "")

  errorFetchingChartData: (error) ->
    $(".chart-container").html("<p>Data is not available at this time.</p>")

  getParamData: ->
    self = @
    @clearXHRs()
    chosenLocos = @all_locomotives.selected
    chosenParam = @all_parameters.getSelected()
    chosenDateRange = @dateRangeSelector.currentDateRange
    dateRange =
      from: chosenDateRange.get("from_date_raw").format("YYYY-MM-DD")
    endDate = chosenDateRange.get("to_date_raw").format("YYYY-MM-DD")
    dateRange.to = endDate unless endDate is moment().format("YYYY-MM-DD")

    paramVariable = chosenParam.get("qes_variable")
    numberOfChosenLocos = chosenLocos.length
    paramsToFetch = []
    i = 0
    while i < chosenLocos.length
      loco = chosenLocos[i]
      data = loco.initMonitoringChart(
        type: @chart_type_text.toLowerCase()
        paramVariable: paramVariable
      )
      paramsToFetch.push(data)
      i++

    # call fetch on all locos, and keep their promises
    _.each paramsToFetch, (paramToFetch) =>
      xhr = paramToFetch.fetch
        data: $.param( dateRange )
        success: _.bind(@processChartData, @)
        error: _.bind(@errorFetchingChartData, @)
      @xhrs[paramToFetch.locomotive.get("id")] = xhr

    $.when.apply(@, @xhrs).done => 
      @finishChart.call(@)
      $('#export-csv').removeClass "disabled"


  resetDatePicker: () ->
    $(".datepicker-popup").hide()
    $( "#datepicker" ).datepicker( "destroy" );

  updateDisplayAfterValid: ->
    isValidated = @paramChart.get("valid")
    if isValidated
      @$chatWrapper.show()
    else
      @$chatWrapper.hide()
      validation = @paramChart.get("validation")
      errors = ""
      @$errorList.empty()
      _.each( validation, (option, i) ->
        if option.valid is false
          errors += "<li>#{option.msg}</li>"
      )
      @$errorList.append(errors)
      @$errorWrap.show()
      $('.chart-actions .button-csv').addClass('disabled')
      
  startChartDisplay: ->
    if @paramChart.get("started") is true
      @trigger("destchosenParam.setSelectedParam()chosenParam.setSelectedParam()royTAReports")
      @resetDatePicker()

  # happens after options are validated
  toggleLoadDisplay: ->
    if @paramChart.get("loading") is true
      if @paramChart.get('valid') is true
        @$errorWrap.hide()
        @$errorList.empty()
      @$loader.show()
      $(".modes-wrap, .mode-report").trigger("close") # Can't use saved var here
      @removeChartButton "exit-ta"
    else
      @$loader.hide()

  addChartButton: (options)->
    $button = $("<a>", $.extend(true,
      href: "#"
      class: "btn btn-default btn-sm"
    , options
    ))

    $button.appendTo @$chartActions

  removeChartButton: (buttonID)->
    @$chartActions.find("##{buttonID}").remove()

  hasChartButton: (buttonID)->
    @$chartActions.find("##{buttonID}").length > 0

  prepChart: ->
    isValidated = @paramChart.get("valid")
    if isValidated == true
      @paramChart.set("loading", true)
      chosenParam = @paramChart.get("parameters").getSelected()
      @paramChart.setChartOptions(chosenParam, @options.chartOptions, @)
      @getParamData()

  initChart: (e) ->
    if e?
      if e.target?
        e.preventDefault()
    @paramChart.set("started", true)
    @paramChart.validateOptions()
    @prepChart()

  ExportCsv: () ->
    self = @
    @clearXHRs()
    chosenLocos = @all_locomotives.selected
    chosenParam = @all_parameters.getSelected()
    chosenDateRange = @dateRangeSelector.currentDateRange
    dateRange =
      from: chosenDateRange.get("from_date_raw").format("YYYY-MM-DD")
    endDate = chosenDateRange.get("to_date_raw").format("YYYY-MM-DD")
    dateRange.to = endDate unless endDate is moment().format("YYYY-MM-DD")

    paramVariable = chosenParam.get("qes_variable")
    numberOfChosenLocos = chosenLocos.length
    paramsToFetch = []
    i = 0
    comma = ""
    url=""
    while i < chosenLocos.length
      loco = chosenLocos[i]
      comma += loco.id + ","
      url = loco.getCsvExportUrl(
        type: @chart_type_text.toLowerCase()
        paramVariable: paramVariable
      )
      
      i++
    if !!url
      $form = self.$('#export-csv-form')
      $form.attr('action', url)
      $form.find('input[name="from"]').val(dateRange.from)
      $form.find('input[name="to"]').val(dateRange.to) if dateRange.to
      $form.find('input[name="loco_ids"]').val(comma)
      $form.submit()

    _.each paramsToFetch, (paramToFetch) =>
      $.ajax(paramToFetch, 
        type: 'GET'
        data: 
          $.param( dateRange )
        dataType: 'text/csv'
        headers: {
          Accept: 'text/csv'
        }
      )

  user: ->
    @options.user

  openModes: (point) ->
    tooltip = point.series.chart.tooltip

    if @user.hasFeatureEnabled("target_analysis")
      point.flag(true)
      @_openModes(point)
      tooltip.hide()


  _openModes: (point) ->
    panelPointData =
      locoName: point.series.name
      time: "#{Highcharts.dateFormat('%Y-%m-%e %H:%M:%S', point.x)} UTC"
      value: point.y
      units: point.series.chart.userOptions.units # Don't judge me
    loco = @locomotives.get(point.series.userOptions.locomotiveID)
    modeValues = @paramChart.get("parameters").selected.getModes()
    rawModes = Cds.targetAnalysis.matchModes(modeValues)
    modesCollection = new Cds.Collections.TargetAnalysisModes(rawModes)
    modesView = new Cds.Views.TargetAnalysisModes(
      collection     : modesCollection
      panelPointData : panelPointData
      parent         : @
      point          : point
      loco           : loco
    )

    # Cancel any currently open mode selection dialog
    $("body").find(".modes-wrap").trigger("cancel")

    $modesViewElement          = $(modesView.render().el)
    $criticalAlarm             = $modesViewElement.find ".critical-alarm-wrap"
    $criticalAlarmNotification = $criticalAlarm.find ".critical-alarm-notification"

    $("body").append($modesViewElement)

    if $criticalAlarm.length
      $criticalAlarm.css 'height', $criticalAlarmNotification.outerHeight()
    $modesViewElement.find('.modes-panel-btm').slideDown
      duration: 200
      step: (now)->

$ ->
  $('body div:not(.choose-param-btn)').on 'click', (event) ->
    if $(event.target).parents('.param-list-choices').length > 0
      return
    $('.param-list-choices').removeClass('open')