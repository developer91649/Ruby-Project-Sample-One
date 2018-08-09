class Cds.Views.ParamOption extends Backbone.View

  template: JST["monitoring/param_option"]
  tagName: "li"

  initialize: ->
    @user = @options.user
  render: ->
    @el.innerHTML = @template(param: @model)
    @addParamIDs()
    this

  addParamIDs: ->
    $(@el).attr("data-id", @model.get("id")).val(@model.get("id"))

  choseParam: ->
    addedParam = @options.paramChart.addParam(@model)
