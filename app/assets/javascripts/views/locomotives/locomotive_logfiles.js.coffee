class Cds.Views.LocomotiveLogfiles extends Backbone.View

  template: JST['locomotives/locomotive_logfiles']

  events:
    "click .on-demand-list .dropdown-menu li": "sendOnDemandRequest"

  initialize: ->
    _.bindAll(@, 'render')

  render: ->
    $(@el).html(@template(loco: @model, system: @options.system))
    @appendLogfiles()
    @getSendFileFlagsCollection()
    @appendQuickview()
    this

  appendQuickview: ->
    locomotiveQuickview = new Cds.Views.LocomotiveQuickview(
      model: @model
      user: @options.user
    )
    @$('.quickview-placeholder').append(locomotiveQuickview.render().el)
    @$('#locomotive-detail-link').parent().addClass('active')

  appendLogfiles: ->
    @model.getLogFiles(system_id: @options.system.get("id"))
    @model.logfiles.fetch(
      success: (response) =>
        @locomotiveLogfilesList = new Cds.Views.LocomotiveLogfilesList(collection: response)
        @locomotiveLogfilesList.parentView = @

        @$('#logfile-list-wrap').empty().append(@locomotiveLogfilesList.render().el)
    )

  getSendFileFlagsCollection: ->
    @model.getSendFileFlags(system_id: @options.system.get("id"))
    @model.sendFileFlags.fetch(
      success: (response) =>
        @sendFileFlagsCollection = response
        # loader not working, loading very fast so took it out for now.
        # @$(".logfile-loading").fadeOut()
        response.forEach( (file) =>
          @sendFileFlagsItem = new Cds.Views.LocomotiveSendFileFlagsItem( model: file )
          @sendFileFlagsItem.parentView = @
          @listenTo(@sendFileFlagsItem, 'pendingUpdated', @appendLogfiles)
          @$("#send-flag-list").append( @sendFileFlagsItem.render().el )
        )
    )

  sendOnDemandRequest: (e) ->
    enum_value = $(e.target).attr("data-enum") * 1
    fileFlag = @sendFileFlagsCollection.find( (item)->
      Number(item.get('enum_value')) == enum_value
    )
    pending = fileFlag.get("pending")
    if pending is false
      fileFlag.save()

_.extend(Cds.Views.LocomotiveDetail.prototype, Cds.Mixins.UI)


class Cds.Views.LocomotiveSendFileFlagsItem extends Backbone.View
  tagName: "li"

  initialize: ->
    @model.on('change:pending', @render, @)
    @model.on('change:pending', @testTrigger, @)

  render: ->
    $(@el).text(@model.get("description"))
      .addClass("pending_#{@model.get("pending")}")
      .attr("data-enum", @model.get("enum_value"))
    this

  testTrigger: ->
    @trigger('pendingUpdated')


class Cds.Views.LocomotiveLogfilesList extends Backbone.View

  template: JST['locomotives/locomotive_logfiles_list']

  initialize: ->
    @collection.on('add', @render, @)

  render: ->
    $(@el).html(@template(log: @collection))
    if @collection.length == 0
      $(@el).find('ul').empty()
      $(@el).find('ul').append("<li><p>There are no logfiles for this locomotive.</p></li>")
    this