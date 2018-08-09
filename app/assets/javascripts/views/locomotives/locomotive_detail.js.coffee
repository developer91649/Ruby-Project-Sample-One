class Cds.Views.LocomotiveDetail extends Backbone.View

  template: JST['locomotives/locomotive_detail']

  events:
    'click #toggle-health': 'toggleWrap'
    'click #toggle-status': 'toggleWrap'
    'click #toggle-fuel-history': 'toggleWrap'
    'click #place-out-of-service': 'toggleOutOfService'
    'click #place-outofservice-link': 'toggleOutOfService'
    'click #confirm-loco-service-modal .confirm-change': 'confirmChangeService'
    'click #software-version-btn': 'showLocoDetailsModal'

  initialize: ->
    _.bindAll(@)
    @startAssetLongPoll()
    @model.on('reset', @render, this)
    @account = @options.account

  render: ->
    $(@el).html(@template(loco: @model))
    # # add locomotive quickview view
    @appendQuickview()
    @fetchLocomotiveData()
    @fetchEngineData()
    @appendFuelConsumption()
    @appendFuelHistory()
    @$("#quickview-wrap").show()
    this

  startAssetLongPoll: () ->
    # start longpoll in locomotive model
    @model.startLongPollingAssets(
      interval: 1
      whatToPoll: ["systemstatus", "healthparams", "statusparams", "locomotive_data", "engine_data"]
      "systemstatus":
        beforeCallback: @appendSystems
      "healthparams":
        beforeCallback: @appendHealthParams
      "statusparams":
        beforeCallback: @appendStatusParams
      "locomotive_data":
        beforeCallback: @createLocoDataViews
      "engine_data":
        beforeCallback: @createEngineDataViews
    )

  goToMonitoring: (e) ->
    e.preventDefault()
    link = $(e.target).attr("data-link")
    Backbone.history.navigate("#{link}/", true)
    @options.mainNav.addActive()

  appendQuickview: ->
    @quickView = new Cds.Views.LocomotiveQuickview(
      model: @model
      user: @options.user
    )
    @$('.quickview-placeholder').empty().append(@quickView.render().el)
    @$('#locomotive-detail-link').parent().addClass('active')

  makeColumns: ->
    length = @$(".system-status-list1 li").length
    second_part = Math.ceil(length/3) - 1
    third_part = length - Math.ceil(length/3)
    thirdList = @$(".system-status-list1 li:gt(#{third_part})").detach()
    secondList = @$(".system-status-list1 li:gt(#{second_part})").detach()
    @$(".system-status-list1").after("<ul class='clearfix system-status-list2 system-status-list'></ul><ul class='clearfix system-status-list3 system-status-list'></ul>")
    secondList.appendTo(".system-status-list2")
    thirdList.appendTo(".system-status-list3")

  appendSystems: (statuses) ->
    $refresh = $(@el).find(".refresh-system-status")
    $refresh.fadeIn()
    $statusList = $(@el).find(".system-status-list1")
    $(@el).find(".system-status-list2").remove()
    $(@el).find(".system-status-list3").remove()
    $statusList.empty()
    statuses.each( (status) =>
      locomotiveSystemStatus = new Cds.Views.LocomotiveSystemstatus(
        model: status
        collection: statuses
        loco: @model
      )
      $statusList.append(locomotiveSystemStatus.render().el)
    )
    @makeColumns()
    $refresh.fadeOut()

  createLocoDataViews: (params) ->
    $refresh = $(@el).find(".refresh-locomotive-data")
    $refresh.fadeIn()
    featuredParamsConfig = @account.getLocoDataViewsConfig(@model)
    $(@el).find(".locomotive-data-wrap ul.locomotive-data-list").empty()
    $(@el).find("ul.fuel-level-list").empty()
    params.each( (param) =>
      qesVariable = param.get("qes_variable")
      if featuredParamsConfig[qesVariable]
        view = new featuredParamsConfig[qesVariable].view(
          model:    param
          config:  featuredParamsConfig[qesVariable].config
          locomotive: @model
        )
        if qesVariable == "fp"
          if $(@el).find(".locomotive-data-wrap ul.locomotive-data-list li.fuel-level-list").size()==0
            $(@el).find(".locomotive-data-wrap ul.locomotive-data-list").append('<li class="featured-param columns2 fuel-level-list"></li>');
          $(@el).find(".locomotive-data-wrap ul.locomotive-data-list li.fuel-level-list").append(view.render().el)
          if param.get("value") >= 65
            $(@el).find(".locomotive-data-wrap ul.locomotive-data-list li.fuel-level-list").addClass('white');
        else if qesVariable == "fl"
          if $(@el).find(".locomotive-data-wrap ul.locomotive-data-list li.fuel-level-list").size()==0
            $(@el).find(".locomotive-data-wrap ul.locomotive-data-list").append('<li class="featured-param columns2 fuel-level-list"></li>');
          $(@el).find(".locomotive-data-wrap ul.locomotive-data-list li.fuel-level-list").append(view.render().el)
        else
          $(@el).find(".locomotive-data-wrap ul.locomotive-data-list").append(view.render().el)
    )
    $refresh.fadeOut()

  createEngineDataViews: (params) ->
    $refresh = $(@el).find(".refresh-engine-data")
    $refresh.fadeIn()
    featuredParamsConfig = @account.getEngineDataViewsConfig()
    $(@el).find(".engine-data-wrap .engine-lists").empty()

    params.each( (param, i) =>
      accountID = @model.get("account_id")
      rowTitle = featuredParamsConfig.row_titles[i]
      $(@el).find(".engine-data-wrap .engine-lists").append("<div class='engine-list#{i}'><h3>#{rowTitle}</h3><ul></ul>")
      _.each(param.attributes, (oneParam) =>
        qesVariable = oneParam.qes_variable
        if featuredParamsConfig[qesVariable]
          view = new featuredParamsConfig[qesVariable].view(
            model:    oneParam
            config:  featuredParamsConfig[qesVariable].config
            locomotive: @model
          )
          if qesVariable == "lo1"
            $(@el).find(".locomotive-data-wrap ul.locomotive-data-list li.lkwh").after(view.render().el)
          else
            $(@el).find(".engine-list#{i} ul").append(view.render().el)
      )
    )
    $refresh.fadeOut()

  fetchLocomotiveData: ->
    @model.locomotive_data.fetch(
      success: (response) =>
        @createLocoDataViews(response)
    )

  fetchEngineData: ->
    @model.engine_data.fetch(
      success: (response) =>
        @createEngineDataViews(response)
    )

  appendHealthParams: (params) ->
    $refresh = $(@el).find(".refresh-health")
    $refresh.fadeIn()
    locomotiveHealthParams = new Cds.Views.LocomotiveHealthParams(
      model: @model.parse(params)
      locomotive: @model
    )
    @$('#health-wrap').html(locomotiveHealthParams.render().el)
    $refresh.fadeOut()

  appendStatusParams: (params) ->
    $refresh = $(@el).find(".refresh-status")
    $refresh.fadeIn()
    locomotiveStatusParams = new Cds.Views.LocomotiveStatusParams(
      model: @model.parse(params)
      locomotive: @model
    )
    @$('#status-wrap').html(locomotiveStatusParams.render().el)
    $refresh.fadeOut()

  toggleOutOfService: (e) ->
    e.preventDefault()
    $modal = $('#confirm-loco-service-modal')
    $modal_body = $modal.find(".modal-body")

    if @model.isOutOfService()
      $modal_body.html("<p>You are placing the locomotive <b>In Service</b> which will enable Email notifications. Are you sure you want to change the locomotive status?</p>")
    else
      $modal_body.html("<p>Email notifications will be disabled when <b>Out of Service</b>. Are you sure you want to change the locomotive status?</p>")
    $modal.modal('show')

  setOutOfServiceMessage: () ->
    if @model.isOutOfService()
      $(".outofservice-section").addClass("active")
    else
      $(".outofservice-section").removeClass("active")
    this
  confirmChangeService: ->
    $('#confirm-loco-service-modal').modal('hide')
    @model.toggleOutOfService
      success: =>
        @quickView.appendDetails()
        @setOutOfServiceMessage()
      error: ->
        alert("There was an error while updating the locomotive")
  appendFuelConsumption: ->
    @model.fuel_consumption.fetch(
      success: (response) =>
        fuel_consumption = response.toJSON()[0]
        fuel_units = fuel_consumption['lfu']
        delete fuel_consumption['lfu']
        $fuel_list = @$('.fuel-consumption-list')
        $(@el).find(".fuel-consumption-loading").fadeOut()
        $fuel_list.empty()
        for own date, value of fuel_consumption
          date_value = date.replace("_", " ")
          historyItem = "<li><span>#{date_value}</span><strong>#{value}</strong> #{fuel_units}</li>"
          $fuel_list.append(historyItem)
        $fuel_list.find("li:last").addClass("last")
    )

  appendFuelHistory: ->
    # add pagination
    @model.fuel_history.fetch(
      success: (response) =>
        fuel_history = response.toJSON()
        $fuel_history_table = @$('.fuel-history')
        for own i, history of fuel_history
          break if i > 5 # Only display six values - Platform #200
          time = moment(history.time_utc)
          historyItem = """
                          <tr>
                            <td>#{time.format("YYYY-MM-DD")}</td>
                            <td class="volume-added">#{history.volume_added} #{history.lfu}</td>
                            <td class="volume-final">#{history.volume_final} #{history.lfu}</td>
                          </tr>
                        """
          $fuel_history_table.append(historyItem)
    )

  showLocoDetailsModal: ->
    $modal = $('#loco-detail-modal')
    $modal_body = $modal.find(".modal-body table")

    $modal_body.append("<tr><td>Locomotive Type</td><td>" + @model.get('locomotive_type').name + "</td></tr>")
    $modal_body.append("<tr><td>Locomotive Name</td><td>" + @model.get('title').name + "</td></tr>")
    $modal_body.append("<tr><td>Locomotive Description</td><td>" + @model.get('description').name + "</td></tr>")
    $modal_body.append("<tr><td>Commission Date</td><td>" + @model.get('commission_date').name + "</td></tr>")
#    $modal_body.append("<tr><td>QES</td><td>" + @model.get('locomotive_type').name + "</td></tr>")
#    $modal_body.append("<tr><td>CDS</td><td>" + @model.get('locomotive_type').name + "</td></tr>")
#    $modal_body.append("<tr><td>CDS CPI CPLD</td><td>" + @model.get('locomotive_type').name + "</td></tr>")
#    $modal_body.append("<tr><td>CDS RSM</td><td>" + @model.get('locomotive_type').name + "</td></tr>")
#    $modal_body.append("<tr><td>CDS RSM CPLD</td><td>" + @model.get('locomotive_type').name + "</td></tr>")
#    $modal_body.append("<tr><td>CDS IOC FPGA</td><td>" + @model.get('locomotive_type').name + "</td></tr>")
#    $modal_body.append("<tr><td>CDS IOC</td><td>" + @model.get('locomotive_type').name + "</td></tr>")
#    $modal_body.append("<tr><td>CDS DIO</td><td>" + @model.get('locomotive_type').name + "</td></tr>")

    $modal.modal("show");

_.extend(Cds.Views.LocomotiveDetail.prototype, Cds.Mixins.UI)
