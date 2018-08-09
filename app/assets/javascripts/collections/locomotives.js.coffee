class Cds.Collections.Locomotives extends Backbone.Collection

  maxLocoLimit: 10
  url: '/api/locomotives'
  model: Cds.Models.Locomotive

  initialize: () ->
    @selected = []
    _.bindAll(@)

  parse: (resp, xhr) ->
    return resp

  removeSelected: (loco_to_remove) ->
    id = loco_to_remove.get("id")
    new_current_locos = _.reject(@selected, (el) =>
      return el.id == id * 1
    )
    @selected = new_current_locos
    loco_to_remove.set( selected: false )

  getSelected: () ->
    @selected

  setSelected: (loco) ->
    if loco.get("selected") is true
      return false
    else
      loco.set( selected: true )
      @selected.push(loco)
      return true