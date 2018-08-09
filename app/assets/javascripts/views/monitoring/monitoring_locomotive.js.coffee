class Cds.Views.MonitoringLocomotive extends Backbone.View

  template: JST["monitoring/locomotive"]
  tagName: "li"
  events:
    'click': 'chooseLoco'
    "click .loco-selected li": "removeLoco"

  initialize: ->
    @user = @options.user
    @chart_type_text = @options.chart_type_text

    # Refer Cds.Models.ParamChart -> chartOptions
    @chartColors = [
      '#2f7ed8',
      '#8bbc21',
      '#910000',
      '#1aadce',
      '#492970',
      '#f28f43',
      '#77a1e5',
      '#c42525',
      '#a6c96a',
      '#f26d7d'
    ]
    _.bindAll(@)
    @model.on("change:selected", @updateLocoView)

  render: ->
    @el.innerHTML = @template(locomotive: @model)
    @el.innerHTML += " <i class='glyphicon glyphicon-arrow-down'></i>"
    @addLocoIDs()
    this

  addLocoIDs: ->
    $(@el).attr("data-id", @model.get("id"))
    $(@el).attr("data-loco-type-id", @model.get("locomotive_type_id"))

  updateLocoView: (options) ->
    isSelected = @model.get("selected")
    typeid     = @model.get('locomotive_type_id')
    chartColors = [
      '#2f7ed8',
      '#8bbc21',
      '#910000',
      '#1aadce',
      '#492970',
      '#f28f43',
      '#77a1e5',
      '#c42525',
      '#a6c96a',
      '#f26d7d'
    ]
    
    if isSelected
      $(@el).addClass('selected')
      index = 0
      locoTitle = @model.get('title')
      _.each(@options.all_locomotives.models, (loco, i) ->
        if loco.get('title') == locoTitle
          index = i 
      )

      $(".loco-selected ul").append(
        "<li data-id='#{@model.get("id")}' data-name='#{@model.get("title")}'>" +
        "<i class='glyphicon glyphicon-exclamation-sign'></i> #{@model.get("title")} " +
        "<i class='glyphicon glyphicon-remove'></i></li>"
      )
      $('.loco-selected li').each( (i,loco) ->
        $(loco).css('background-color',chartColors[i])
      )
      $('#loco-type-select').selectpicker('val',typeid)
      $('#loco-type-select').trigger('change')

    if $(".loco-selected ul li").length == 0
      $(".loco-selected h3 span").show()
      $(".param-list-choices a").addClass('disabled')
      $(".param-list-choices").removeClass('open')
    else
      $(".loco-selected h3 span").hide()
      $(".param-list-choices a").removeClass('disabled')

  chooseLoco: (e) ->
    # simple alert for now for loco limit
    if @options.all_locomotives.selected.length == 10
      alert("Selected loco limit reached")
      return false
    addedLoco = @model.setSelectedLoco()
    @options.chartView.initChart(@model)
