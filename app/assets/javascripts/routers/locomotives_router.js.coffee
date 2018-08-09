# extend router to check for user first
class Backbone.FlexRouter extends Backbone.Router
  route: (route, name, callback = null) ->
    callback = @[name] if ! callback
    super route, name, ->
      that = this
      this.arguments = arguments
      this.callback = callback
      if !@user?
        @user = new Cds.Models.User()
        @user.fetch(
          success: (response) =>
            @user = response
            @addActiveMainNav()
            $(".customer-logo-wrap a").on("click", $.proxy( @toggleHeader, @ ))
            @initHeaderPref()
            @addUserPrefTime()
            result = that.callback && that.callback.apply(that, that.arguments)
            return result
          # error: (response) =>
          #   console.log response
        )
      else if @user?
        result = callback && callback.apply(@, arguments)
        return result
      # @trigger 'route:after'

class Cds.Routers.Locomotives extends Backbone.FlexRouter
  routes:
    # temp fix for trailing slash issue between rails and backbone
    'fleetmanager/': 'index'
    'fleetmanager': 'index'
    'reports/': 'renderReports'
    'reports': 'renderReports'
    'reports/excess-idle-report': 'renderExcessIdleReport'
    'reports/reliability-report': 'reliabilityReport'
    'locomotives/:id': 'locomotiveDetail'
    'locomotives/:id/fault-summary': 'faultSummary'
    'locomotives/:id/alarms/:alarm_id': 'alarmDiagnostics'
    'locomotives/:id/faults/:fault_id/:time': 'faultDiagnostics'
    'locomotives/:id/maintenance': 'locomotiveMaintenance'
    'locomotives/:id/maintenance/snapshots/:system_id': 'locomotiveLogfiles'
    'health/*param': 'healthMonitoring'
    'status/*param': 'statusMonitoring'
    'kb/': 'knowledgebase'
    'kb/:id': 'knowledgebaseDetail'
    'resources/': "getResources"

  # ew this should be in a view, but because of rails authentication, difficult.
  initHeaderPref: (e) ->
    $btn = $(".customer-logo-wrap a")
    toggleEl = $btn.attr('data-toggle')
    $elToToggle = $("##{toggleEl}-wrap")
    userPref =  @user.get( "pref_header_image" )
    userPref = if userPref is true then true else false
    if userPref is true
      $(".full-header").addClass("customer-logo-visible")
      $elToToggle.show()
      $btn.text("Hide -")
    else
      $(".full-header").removeClass("customer-logo-visible")
      $elToToggle.hide()
      $btn.text("Show +")

  getUserPrefTime: ->
    time = Cds.time.getUserPrefTime(
      user: @user
      time: moment.utc()
    )
    time = time.slice(0, -3)

  addUserPrefTime: ->
    time = @getUserPrefTime()
    $(".user-time").html("My Pref Time: <span>#{time}</span>")
    setInterval( () =>
      time = @getUserPrefTime()
      $(".user-time span").text(time)
    , 60000)

  addActiveMainNav: ->
    # add active state to li by matching first segment of the url
    # could load them via model, but since they won't change often, seems unecessary
    # seems a bit funky, maybe there is a better way
    firstUrlSegment = $(location).attr('pathname')
    firstUrlSegment.indexOf(1)
    firstUrlSegment.toLowerCase()
    firstUrlSegment = firstUrlSegment.split("/")[1]
    fleetmanagerActive = ["fleetmanager", "locomotives"]
    $(".main-nav li").removeClass("active")
    $(".main-nav li").each( (i, el) =>
      link = $(el).children('a').attr('data-link')
      if _.contains(fleetmanagerActive, firstUrlSegment)
        $(".main-nav a[data-link='fleetmanager']").parent("li").addClass("active")
      if firstUrlSegment is link
        $(el).addClass("active")
    )

  saveHeaderUserPref: () ->
    userPref = @user.get("pref_header_image")
    @user.save( "pref_header_image", !userPref,
      error: (response) =>
        new Cds.Views.Alert(
          status: "error"
          msg: "There was a problem saving your user preference."
        )
      success: (response) =>
        if !userPref is true
          msg = "Your user preference was saved to show the masthead image."
        else
          msg = "Your user preference was saved to NOT show the masthead image."
        new Cds.Views.Alert(
          status: "success"
          msg: msg
        )
    )

  toggleHeader: (e) ->
    toggleEl = $(e.target).attr('data-toggle')
    @saveHeaderUserPref()
    $("##{toggleEl}-wrap").slideToggle( () ->
      if $(@).is(":visible")
        $(".full-header").addClass("customer-logo-visible")
      else
        $(".full-header").removeClass("customer-logo-visible")
      $btn = $(@).prev("a")
      $btn.text (if $(@).is(":visible") then "Hide -" else "Show +")
    )

  initPageLoader: () ->
    @$pageLoader.show()

  stopPageLoader: () ->
    @$pageLoader.hide()

  after: (pageHTML) ->
    @$placeholderDiv.html(pageHTML)
    @stopPageLoader()

  afterError: ->
    @$placeholderDiv.html("<p>There was an error loading the feed.</p>")
    @stopPageLoader()

  setPlaceholderDiv: ->
    @$placeholderDiv = $('.app-placeholder')
    if @$placeholderDiv.length == 0
      placeholderHTML = """
                        <section class="row clearfix">
                          <div class="sixteen columns alpha">
                            <div class="app-placeholder">
                            </div>
                          </div>
                        </section><!-- /row -->
                        """
      $(".yield-wrap").append(placeholderHTML)
      @$placeholderDiv = $('.app-placeholder')

  before: ->
    @$pageLoader = $(".page-loader")
    @setPlaceholderDiv()
    @initPageLoader()
    @$placeholderDiv.empty()
    # stop all polling
    if Backbone.Poller?
      Backbone.Poller.reset()

  initialize: ->

  index: ->
    @before()
    locomotives = new Cds.Collections.Locomotives()
    locomotives.fetch(
      success: (response) =>
        view = new Cds.Views.LocomotivesIndex(
          collection: response
          user: @user
        )
        @after( view.render().el )
      error: (model, xhr, options) =>
        @afterError()
    )

  getOneLocomotive: (id) ->
    @currentLocomotive = new Cds.Models.Locomotive(id: id)

  renderLocomotiveDetail: () ->
    view = new Cds.Views.LocomotiveDetail(
      model: @currentLocomotiveFetched
      user: @user
      account: @currentLocomotiveAccount
    )
    @after( view.render().el )
    
  locomotiveDetail: (loco_id) ->
    @before()
    if @currentLocomotiveFetched? and @currentLocomotiveFetched.get("id") == loco_id
      @renderLocomotiveDetail()
    else
      @getOneLocomotive(loco_id)
      @currentLocomotive.fetch(
        success: (response) =>
          @currentLocomotiveFetched = response
          accountID = @currentLocomotiveFetched.get("account_id")
          account = new Cds.Models.Account(id: accountID)
          account.fetch
            success: (response) =>
              @currentLocomotiveAccount = response
              @renderLocomotiveDetail()
            error: =>
              @afterError()
        error: (model, xhr, options) =>
          @afterError()
      )

  renderFaultSummary: () ->
    view = new Cds.Views.LocomotiveFaultSummary(
      model: @currentLocomotiveFetched
      user: @user
    )
    @after( view.render().el )

  faultSummary: (loco_id) ->
    @before()
    if @currentLocomotiveFetched? and @currentLocomotiveFetched.get("id") == loco_id
      @renderFaultSummary()
    else
      @getOneLocomotive(loco_id)
      @currentLocomotive.fetch(
        success: (response) =>
          @currentLocomotiveFetched = response
          @renderFaultSummary()
        error: (model, xhr, options) =>
          @afterError()
      )

  renderReports: ->
    @before()
    locomotives = new Cds.Collections.Locomotives()
    locomotives.fetch(
      success: (response) =>
        view = new Cds.Views.LocomotivesReports(
          collection: response
          user: @user
        )
        @after( view.render().el )
      error: (model, xhr, options) =>
        @afterError()
    )


  reliabilityReport: ->
    @before()
    locomotives = new Cds.Collections.Locomotives()
    locomotives.fetch(
      success: (response) =>
        view = new Cds.Views.LocomotivesReliabilityReport(
          collection: response
          user: @user
        )
        @after( view.render().el )
      error: (model, xhr, options) =>
        @afterError()
    )

  renderExcessIdleReport: ->
    @before()
    locomotives = new Cds.Collections.Locomotives()
    locomotives.fetch(
      success: (response) =>
        view = new Cds.Views.LocomotivesExcessIdleReport(
          collection: response
          user: @user
        )
        @after( view.render().el )
      error: (model, xhr, options) =>
        @afterError()
    )
  ###
  Fault Diagnostics
  For those times where we have a fault we want to check the diagnostics for
  but we don't actually have the alarm id. Uses a datetime passed as a parameter
  to request a health snapshot.

  @param {string} loco_id
  @param {string} fault_id The CMS-assigned ID of the fault
  @param {string} utc_time The time to pull for the AHS
  ###
  faultDiagnostics: (loco_id, fault_id, utc_time) ->
    @before()
    if @currentLocomotiveFetched? and @currentLocomotiveFetched.get("id") == loco_id
      @renderFaultDiagnostics(fault_id, utc_time)
    else
      @getOneLocomotive(loco_id)
      @currentLocomotive.fetch(
        success: (response) =>
          @currentLocomotiveFetched = response
          @renderFaultDiagnostics(fault_id, utc_time)
        error: (model, xhr, options) =>
          @afterError()
      )

  renderFaultDiagnostics: (fault_id, utc_time) ->
    fault = new Cds.Models.Fault(id: fault_id)
    fault.fetch(
      success: (model, response, options) =>
        view = new Cds.Views.FaultDiagnostics(
          loco     : @currentLocomotiveFetched
          alarm    : null
          fault    : model
          user     : @user
          utc_time : utc_time
        )
        console.log model.get("qes_variable")
        @after( view.render().el )
    )

  ###
  Alarm Diagnostics
  For when we actually have an alarm ID.

  @param {string} loco_id
  @param {string} alarm_id The LIIS ID of the alarm from the mongo store
  ###
  alarmDiagnostics: (loco_id, alarm_id) ->
    @before()
    if @currentLocomotiveFetched? and @currentLocomotiveFetched.get("id") == loco_id
      @renderAlarmDiagnostics(alarm_id)
    else
      @getOneLocomotive(loco_id)
      @currentLocomotive.fetch(
        success: (response) =>
          @currentLocomotiveFetched = response
          @renderAlarmDiagnostics(alarm_id)
        error: (model, xhr, options) =>
          @afterError()
      )

  renderAlarmDiagnostics: (alarm_id) ->
    alarm = new Cds.Models.Alarm(id: alarm_id)
    alarm.fetch(
      success: (response) =>
        view = new Cds.Views.FaultDiagnostics(
          loco  : @currentLocomotiveFetched
          alarm : response
          fault : response.get("fault")
          user  : @user
        )
        @after( view.render().el )
    )

  renderLocomotiveMaintenance: () ->
    view = new Cds.Views.LocomotiveMaintenance(
      model: @currentLocomotiveFetched
      user: @user
    )
    @after( view.render().el )

  locomotiveMaintenance: (loco_id) ->
    @before()
    if @currentLocomotiveFetched? and @currentLocomotiveFetched.get("id") == loco_id
      @renderLocomotiveMaintenance()
    else
      @getOneLocomotive(loco_id)
      @currentLocomotive.fetch(
        success: (response) =>
          @currentLocomotiveFetched = response
          @renderLocomotiveMaintenance()
        error: (model, xhr, options) =>
          @afterError()
      )

  renderLocomotiveLogfiles: (system_id) ->
    @currentLocomotiveFetched.systems.fetch(
      success: (response) =>
        system = response.get(system_id)
        view = new Cds.Views.LocomotiveLogfiles(
          model: @currentLocomotiveFetched
          system: system
          user: @user
        )
        @after( view.render().el )
    )

  locomotiveLogfiles: (loco_id, system_id) ->
    @before()
    if @currentLocomotiveFetched? and @currentLocomotiveFetched.get("id") == loco_id
      @renderLocomotiveLogfiles(system_id)
    else
      @getOneLocomotive(loco_id)
      @currentLocomotive.fetch(
        success: (response) =>
          @currentLocomotiveFetched = response
          @renderLocomotiveLogfiles(system_id)
        error: (model, xhr, options) =>
          @afterError()
      )

  renderKnowledgebase: () ->
    view = new Cds.Views.KnowledgebaseList(
      collection: @kb_entries
      user: @user
    )
    @after( view.render().el )

  knowledgebase: () ->
    @before()
    if @kb_entries?
      @renderKnowledgebase()
    else
      kb_entries_as_faults = new Cds.Collections.Faults()
      kb_entries_as_faults.fetch(
        success: (kb_entries) =>
          @kb_entries = kb_entries
          @renderKnowledgebase()
        error: (model, xhr, options) =>
          @afterError()
      )

  renderKnowledgebaseDetail: (kb_entry) ->
    view = new Cds.Views.KnowledgebaseDetail(
      model: kb_entry
      user: @user
    )
    @after( view.render().el )

  knowledgebaseDetail: (kb_id) ->
    @before()
    if @kb_entries?
      kb_entry = @kb_entries.get(kb_id)
      @renderKnowledgebaseDetail(kb_entry)
    else
      kb_entry = new Cds.Models.Fault(id:kb_id)
      kb_entry.fetch(
        success: (kb_entry) =>
          @renderKnowledgebaseDetail(kb_entry)
        error: (model, xhr, options) =>
          @afterError()
      )

  renderResources: () ->
    view = new Cds.Views.ResourcesList(
      collection: @resources
      user: @user
    )
    @after( view.render().el )

  getResources: () ->
    @before()
    if @resources?
      @renderResources()
    else
      resources = new Cds.Collections.Resources()
      resources.fetch(
        success: (resources) =>
          @resources = resources
          @renderResources()
        error: (model, xhr, options) =>
          @afterError()
      )

  # /health
  # or optional params: /health/:qes_variable/:loco_id_assigned, e.g. /health/mi26/8/
  healthMonitoring: (urlParams) ->
    @before()
    # there are 2 optional parameters:
    # parameter qes varaible
    # locomotive id
    if urlParams
      urlParams = urlParams.split("/")
      param = urlParams[0]
      locomotiveID = urlParams[1]

    parameters = new Cds.Collections.HealthParams()
    locomotive_types = new Cds.Collections.LocomotiveTypes()
    locomotives = new Cds.Collections.LocomotivesStatic()
    $.when(locomotive_types.fetch(), locomotives.fetch(), parameters.fetch()).done =>
      paramChart = new Cds.Models.ParamChart(
        locomotives: locomotives
        parameters: parameters
      )
      opts =
        collection: locomotives
        locomotive_types: locomotive_types
        paramChart: paramChart
        chart_type_text: "HEALTH"
        parameters: parameters
        user: @user
        urlSelected:
          param: param
          locomotiveID: locomotiveID
        chartOptions: {}
      view = new Cds.Views.MonitoringIndex( opts )
      @after( view.render().el )

  # /status
  # or optional params: /status/:qes_variable/:loco_id_assigned, e.g. /status/mi26/8/
  statusMonitoring: (urlParams) ->
    @before()
    if urlParams
      urlParams = urlParams.split("/")
      param = urlParams[0]
      locomotiveID = urlParams[1]
    parameters = new Cds.Collections.StatusParams()
    locomotive_types = new Cds.Collections.LocomotiveTypes()
    locomotives = new Cds.Collections.LocomotivesStatic()
    $.when(locomotive_types.fetch(), locomotives.fetch(), parameters.fetch()).done =>
      paramChart = new Cds.Models.ParamChart(
        locomotives: locomotives
        parameters: parameters
      )
      opts =
        collection: locomotives
        locomotive_types: locomotive_types
        paramChart: paramChart
        chart_type_text: "STATUS"
        parameters: parameters
        user: @user
        urlSelected:
          param: param
          locomotiveID: locomotiveID
        chartOptions:
          chart_max: 1.1
          chart_min: -0.1
          yAxisOptions:
            tickInterval: 1
            gridLineWidth: 0
            minorGridLineWidth: 0
            endOnTick: false
            startOnTick: false
            categories: ['OFF', 'ON', '']

      view = new Cds.Views.MonitoringIndex( opts )
      @after( view.render().el )
