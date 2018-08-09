class Cds.Views.AlarmLi extends Backbone.View
  tagName: "li"
  initialize: ->
    @loco_id  = @options.loco_id
    @fault    = @options.fault
    @time_utc = @options.time_utc
  render: ->
    @$el.html "<a href='/locomotives/#{@loco_id}/faults/#{@fault.get('qes_variable')}/#{@time_utc}'>#{@fault.get('title')}</a>"
    @