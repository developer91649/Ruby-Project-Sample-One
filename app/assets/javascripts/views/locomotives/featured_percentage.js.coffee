class Cds.Views.FeaturedPercentage extends Backbone.View
  className: "percent-level-wrap"
  template: JST['locomotives/featured_percentage']

  initialize: ->
    if @options.config.title
      @model.set("title", @options.config.title)
    if @model instanceof Backbone.Model
      @param = @model.toJSON()
      # Would this work? Hard to test
      # @options.model.on("change:value", @test)
    else
      @param = @model


  render: ->
    $(@el).html(@template(param: @param))
    $(@el).find(".percent-level").css("width": "#{@model.get("value")}%")
    this
