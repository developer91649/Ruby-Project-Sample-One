class Cds.Views.LocomotivesReliabilityReport extends Backbone.View
  template: JST['locomotives/reliability_report']
  # events:

  initialize: ->
    @user = @options.user
    @account_id = @collection.models[0].get("account_id")

  render : ->
    $(@el).html(@template(locomotive: @model, user: @user))
    _.defer( () =>
      @dateOptions = Cds.charts.getDateOptions()
      @dateRangeSelector = new Cds.Views.DateRangeSelector(
        dateOptions: @dateOptions
        range: true
        time: false
      )
      @$('.selectpicker').selectpicker()
      @dateRangeSelector.currentDateRange.on("change:from_display", @updateFromDisplay)
      @dateRangeSelector.currentDateRange.on("change:to_display", @updateToDisplay)
      @dateRangeSelector.currentDateRange.on("change:from_date_raw", @initChart, @)
      $("#date-range-selector").replaceWith(@dateRangeSelector.render().$el)
      @dateRangeSelector.$buttonGroup.addClass "btn-group-sm"
      @$(".date-options a:first").trigger('click')
    , this)
    setTimeout(@addDataTableStyle, 10)
    this
  

  addDataTableStyle: ->
    table = $('#sample').DataTable(
      scrollY: "300px"
      scrollX: true
      scrollCollapse: true
      paging: false
      fixedColumns:
            leftColumns: 1
            rightColumns: 1
    )

  updateFromDisplay: () ->
    display_time = @get("from_display")
    $(".date-range-display .chosen-from-date").text(display_time)
    $("#from").val(display_time)

  updateToDisplay: () ->
    display_time = @get("to_display")
    $(".date-range-display .chosen-to-date").text(display_time)
    $("#to").val(display_time)
