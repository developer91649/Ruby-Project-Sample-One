class Cds.Views.DateRangeSelector extends Backbone.View
  template  : JST['elements/_date_range_selector']
  className : 'date-selection-wrap row'
  id        : 'date-range-selector'

  # events:
  #   'click #locomotive-detail-nav button': 'navigateInQuickview'
  initialize: ->
    @dateOptions      = @options.dateOptions
    @currentDateRange = new Cds.Models.DateRange
    @range            = @options.range
    @time             = @options.time
    @to               = @options.to # To
    if @dateOptions?
      @currentDateOption = @dateOptions[0].hours

  render: ->
    $template = $(@template())
    $template.appendTo @$el

    @$buttonGroup = @$el.find(".date-options")
    @addDateOptions()
    if @dateOptions?
      @highlightDateOption(@dateOptions[0].hours)
      @selectDateRange(@dateOptions[0].hours, @to)

    @addCustomPopup()
    @

  ###
  Append date buttons to the button group

  @param {object} dateOption object
  ###
  appendDateButton: (dateOption)->
    $button = new Cds.Views.Button(html: dateOption.text).render().$el
    $button.attr id: "date-option-#{dateOption.hours}"
    $button.data hours: dateOption.hours
    $button.appendTo @$buttonGroup
    $button

  ###
  Add the default date options
  ###
  addDateOptions: ->
    _.each(@dateOptions, (dateOption) =>
      $button = @appendDateButton(dateOption)
      $button.click (e) =>
        e.preventDefault()
        hours = $button.data "hours"

        @currentDateOption = hours
        @highlightDateOption hours
        @selectDateRange hours, @to
        @dateRangeCustomPopup.close()
    )

  ###
  Add custom date range popup
  ###
  addCustomPopup: ->
    @dateRangeCustomPopup = new Cds.Views.DateRangeCustomPopup(
      parent : @
      range  : @range
      time   : @time
    )
    @$el.find("#date_range_custom_popup").replaceWith @dateRangeCustomPopup.render().$el
    $button = @appendDateButton text: "Custom", hours: "custom"
    $button.click (e) =>
      e.preventDefault()

      popupOpen = @dateRangeCustomPopup.toggle()
      if popupOpen then @highlightDateOption("custom") else @highlightDateOption(@currentDateOption)

  ###
  Select the date range

  @param {string|Moment} from
  @param {string|Moment} to
  ###
  selectDateRange: (from, to = moment())->
    if _.findWhere(@dateOptions, { hours: from })?
      from = moment(to).subtract 'hours', from

    @currentDateRange.set(
      from_date_raw : from
      to_date_raw   : to
    )

  ###
  Highlights a selected date option

  @param {string} hours The hours property of the date range (kinda like the id)
  ###
  highlightDateOption: (hours)->
    $button = @$el.find("#date-option-#{hours}")
    $button.addClass "active"
    $button.siblings().removeClass "active"