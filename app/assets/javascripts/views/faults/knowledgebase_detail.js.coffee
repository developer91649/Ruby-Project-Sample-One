class Cds.Views.KnowledgebaseDetail extends Backbone.View
  template: JST['faults/knowledgebase_detail']

  initialize: ->
    _.bindAll(@)

  render: ->
    $(@el).html(@template( fault: @model.toJSON() ) )
    this
