class Cds.Views.LocomotiveStatusParams extends Backbone.View
  template: JST['locomotives/locomotive_statusparams']
  tagName: 'ul'
  className: 'parameter-list status-list columns eight alpha'

  initialize: ->
    @locomotive = @options.locomotive

  render: ->
    $(@el).html(@template(params: @model, locomotive: @options.locomotive))
    _.defer( () =>
      @makeColumns()
    , this)
    this

  makeColumns: ->
    half = $(@el).children("li").length
    half = Math.ceil(half/2) - 1
    halfOfList = $(".status-list li:gt(#{half})").detach()
    $(@el).after("<ul class='parameter-list status-list parameter-list-right columns eight omega'></ul>")
    halfOfList.appendTo(".status-list.parameter-list-right")
    $(".status-list li").on("click", $.proxy( @goToChosenMonitoring, @ ) )
