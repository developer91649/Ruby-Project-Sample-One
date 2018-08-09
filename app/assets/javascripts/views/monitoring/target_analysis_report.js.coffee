class Cds.Views.TargetAnalysisReport extends Backbone.View
  template: JST["monitoring/target_analysis_report"]
  className: "dialog ta-dialog ta-mode-report"
  events:
    "click .close-btn": "destroy"
    "close": "close"
    "open": "open"
    "destroy": "destroy"

  initialize: ->
    @parent     = @options.parent
    @point      = @options.point

  render: ->
    $el = @$el

    locals =
      point      : @point
      locoTitle  : @options.loco.get("title")
      title      : @options.mode.get("title")

    $el.html( @template( locals ) )
    $el.css
      borderColor: @point.series.color

    @$dataWrapper = $el.find('.dialog-data')

    @

  open: ->
    @$el.show()
    $el = @$el
    modeMenu = @parent
    page     = modeMenu.parent

    if !page.hasChartButton("exit-ta")
      page.addChartButton(
        id:     "exit-ta"
        text:   "Exit Target Analysis"
        click: (e)->
          e.preventDefault()
          console.log "exit ta clicked"
          page.trigger("destroyTAReports")
      )

      page.once "destroyTAReports", (e)->
        $('.ta-dialog').trigger "destroy"

  displayData: (data, options) ->
    collection = _.sortBy data.toJSON(), (row) ->
      row.parameterName

    $table = $( options.template(collection: collection, displayedParams: options.displayedParams) )
    $table.find('thead th, thead tr').css
      backgroundColor: @point.series.color
    $table.find('tbody td.changed').css
      color: @point.series.color
    @$dataWrapper.html $table

  close: ->
    @$el.remove() # Close the modal

  destroy: ->
    modeMenu = @parent
    page     = modeMenu.parent

    @point.flag(false)
    @point.mark(false) # Unmark the point
    @$el.trigger "close"
    if $('.ta-dialog').length < 1
      page.removeChartButton "exit-ta"
      page.paramChart.get("chart").selectedPointCount = 0
