class Cds.Views.MonitoringLocomotiveType extends Backbone.View

  template: JST["monitoring/locomotive_type"]
  tagName: "option"

  initialize: ->
    @locomotive_types = @options.locomotive_types
    _.bindAll(@)

  render: ->
    @el.innerHTML = @template(locomotive_type: @model)
    @addLocoIDs()
    this

  addLocoIDs: ->
    $(@el).attr('value', @model.id)
