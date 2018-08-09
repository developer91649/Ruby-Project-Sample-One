class Cds.Views.LocomotiveHealthParams extends Backbone.View
  template: JST['locomotives/locomotive_healthparams']
  tagName: 'ul'
  className: 'parameter-list health-list columns eight alpha'

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
    halfOfList = $(".health-list li:gt(#{half})").detach()
    $(@el).after("<ul class='parameter-list health-list parameter-list-right columns eight omega'></ul>")
    halfOfList.appendTo(".health-list.parameter-list-right")
    $(".health-list li").on("click", $.proxy( @goToChosenMonitoring, @ ) )

