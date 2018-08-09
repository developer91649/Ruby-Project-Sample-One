class Cds.Views.DateRangeCustomPopup extends Backbone.View
  template  : JST['elements/_date_range_custom_popup']
  className : 'date-picker-wrap row'
  id        : 'date-range-custom-popup'

  events:
    'open': 'open'
    'close': 'close'
    'click #apply-date-selection': 'applyDateSelection'
    'blur #from': 'handleInputBlur'
    'blur #time_from': 'handleInputBlur'

  initialize: ->
    @parent            = @options.parent
    @selectedDateRange = new Cds.Models.DateRange
    @datepickerId      = "datepicker-#{moment().format("u")}"

  render: ->
    @$popup = $(@template(range: @parent.range, time: @parent.time, datepickerId: @datepickerId))
    @$popup.appendTo @$el

    @selectedDateRange.on("change:from_date_raw", () =>
      @updateDateInput("from")
      @updateTimeInput("from")
    , @)
    @selectedDateRange.on("change:to_date_raw", () =>
      @updateDateInput("to")
      @updateTimeInput("to")
    , @)

    @

  toggle: ->
    if @$popup.is ":hidden" then @open() else @close()

  open: ->
    currentDateRange = @parent.currentDateRange
    from             = currentDateRange.get("from_date_raw")
    to               = currentDateRange.get("to_date_raw")

    @updateDateSelection(from, to)
    @renderDatePicker()
    @$popup.show()
    true

  close: ->
    @$popup.hide()
    @$("##{@datepickerId}").datepicker("destroy")
    false

  renderDatePicker: ->
    fromSelected = false

    @$("##{@datepickerId}").datepicker(
      numberOfMonths: 3
      maxDate: '+0m +0w'
      minDate: new Date(2013, 1 - 1, 1)
      altFormat: "MM d, yy"
      beforeShowDay: (date) =>
        from_date = @selectedDateRange.get("from_date_raw").clone()
        from_date.hours(0).minutes(0).seconds(0).milliseconds(0)
        to_date = @selectedDateRange.get("to_date_raw").clone()
        to_date.hours(11).minutes(59).seconds(59).milliseconds(99)

        # disable dates before chosen from date, if one has been chosen
        if fromSelected and @selectedDateRange.get("from_date_raw") > moment(date)
          return [false]
        if from_date <= date <= to_date
          [true, "ui-state-chosen"]
        else
          [true]
      onSelect: (date, inst) =>
        if @parent.range
          if fromSelected is false
            @updateDateSelection moment(date)
            fromSelected = true
          else
            fromSelected = false
            @updateDateSelection @selectedDateRange.get("from_date_raw"), moment(date)
        else
          @updateDateSelection moment(date), @parent.to

        inst.settings.beforeShowDay(date)
    )

  updateDateSelection: (from, to)->
    to = from unless to?

    @selectedDateRange.set(
      from_date_raw: from
      to_date_raw: to
    )

  handleInputBlur: (e)->
    extreme = $(e.currentTarget).parents(".datetime-group").data "extreme"
    @parseInput extreme

  parseInput: (extreme)->
    if @$el.find(".datetime-group[data-extreme='#{extreme}']").length > 0
      date = @$el.find("##{extreme}").val() || ""
      time = @$el.find("#time_#{extreme}").val() || ""
      datetime = moment("#{date} #{time}")
      @selectedDateRange.set "#{extreme}_date_raw", datetime

  updateDateInput: (id)->
    val = @selectedDateRange.get("#{id}_display")
    @$el.find("##{id}").val val

  updateTimeInput: (id)->
    val = @selectedDateRange.get("#{id}_time")
    @$el.find("#time_#{id}").val val

  applyDateSelection: (e)->
    e.preventDefault()

    @parseInput("from")
    @parseInput("to")

    @parent.currentDateRange.set
      from_date_raw: @selectedDateRange.get("from_date_raw")
      to_date_raw: @selectedDateRange.get("to_date_raw")
    @parent.currentDateOption = "custom"
    @close()