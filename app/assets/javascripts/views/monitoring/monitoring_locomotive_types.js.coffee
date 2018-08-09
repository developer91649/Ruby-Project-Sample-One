class Cds.Views.MonitoringLocomotiveTypes extends Backbone.View

  template: ""
  tagName: "select"
  events:
    'change': 'chooseLocoType'
  attributes:
    'id': 'monitoring-locomotive-type-selector'

  initialize: ->
    @locomotive_types = @options.locomotive_types
    @chartView = @options.chart_view
    _.bindAll(@)

  render: ->
    @addLocoTypes()
    this

  addLocoTypes: ->
    @locomotive_types.forEach( (model) =>
      locoTypeView = new Cds.Views.MonitoringLocomotiveType(
        model: model
      )
      $(@el).append(locoTypeView.render().el)
    )

  chooseLocoType: (e) ->
    @chartView.updateLocoType(e.currentTarget.value * 1)
