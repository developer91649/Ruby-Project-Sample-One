# Sample model:
# {"system_id":"1","system_name":"GPS","system_status":1}
class Cds.Views.LocomotiveSystemstatus extends Backbone.View
  template: JST['locomotives/locomotive_system_status']
  tagName: 'li'

  initialize: ->
    @loco = @options.loco

  render: ->
    # index needs to be id and these need to be store in the cms
    index = @collection.indexOf(@model) + 1
    $(@el).html(@template(system: @model))
    $(@el).attr("id", @model.get("system_name"))
    @getStatusText()
    @addToolTip()
    this

  addToolTip: ->
    that = @
    $(@el).tooltip(
      title: ->
        that.model.get("systemStatusTooltipText")
    )

  getStatusText: () ->
    @model.getSystemStatusText(@loco.get("account_id"))
    $(@el).find("strong").text(@model.get("systemStatusText"))
