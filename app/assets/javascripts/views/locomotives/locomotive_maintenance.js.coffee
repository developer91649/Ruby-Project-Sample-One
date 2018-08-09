class Cds.Views.LocomotiveMaintenance extends Backbone.View

  template: JST['locomotives/locomotive_maintenance']
  events:
    "click .snapshot-list li": "navigateSnapshots"
    "click #myTabs a": "renderTab"

  initialize: ->
    @model.on('reset', @render, this)

  render: ->
    $(@el).html(@template(locomotive: @model))
    @appendQuickview()
    @appendSystemsWithLogs()
    @appendSoftwareList()
    this

  renderTab: (e) ->
    e.preventDefault()
    $(@).tab 'show'
    return
    
  appendQuickview: ->
    locomotiveQuickview = new Cds.Views.LocomotiveQuickview(
      model: @model
      user: @options.user
    )
    @$('.quickview-placeholder').append(locomotiveQuickview.render().el)
    @$('#locomotive-detail-link').parent().addClass('active')

  appendSystemsWithLogs: ->
    @model.systems.fetch(
      success: (response) =>
        $(@el).find(".snapshot-loading").fadeOut()
        locomotiveSystemsList = new Cds.Views.LocomotiveSystemsList(
          model: response
          locomotive: @model
        )
        @$('.snapshot-list-header').after(locomotiveSystemsList.render().el)
    )

  appendSoftwareList: ->
    @model.locomotive_software.fetch(
      success: (response) =>
        software = response.toJSON()[0]
        $(@el).find(".software-loading").fadeOut()
        @$('.loco-software-list').empty()
        for own system, version of software
          # temp - Brian might do this on his side.
          if version != "null"
            locomotiveSoftwareItem = "<li><strong>#{system}:</strong> #{version}</li>"
            @$('.loco-software-list').append(locomotiveSoftwareItem)
     )

  navigateSnapshots: (e) ->
    systemChoice = $(e.target).attr("data-systemid")
    Backbone.history.navigate("locomotives/#{@model.get('id')}/maintenance/snapshots/#{systemChoice}", true)



class Cds.Views.LocomotiveSystemsList extends Backbone.View

  template: JST['locomotives/locomotive_systems_logfiles_list']

  render: ->
    $(@el).html(@template(system: @model, locomotive: @options.locomotive))
    this

