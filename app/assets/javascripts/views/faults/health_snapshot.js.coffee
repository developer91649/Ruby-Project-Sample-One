class Cds.Views.HealthSnapshot extends Backbone.View
  template: JST["faults/health_snapshot"]
  className: "dialog health-snapshot"
  events:
    "click .close-btn": "destroy"
    "close": "close"

  render: ->
    @$el.html( @template( @options ) )
    @$dataWrapper = @$el.find('.dialog-data')
    @

  open: ->
    @$el.show()

  displayData: (data) ->
    parameters = _.sortBy data.toJSON(), (parameter) -> parameter.parameterName

    template = JST["faults/health_snapshot_data"]
    @$dataWrapper.html template( $.extend(@options, parameters: parameters ))

  close: ->
    $(@el).remove() # Close the modal

  destroy: ->
    $(@el).trigger("close")