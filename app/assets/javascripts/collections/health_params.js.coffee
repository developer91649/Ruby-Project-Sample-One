class Cds.Collections.HealthParams extends Backbone.Collection

  url: '/api/healthmonitoring'
  model: Cds.Models.HealthParam

  initialize: () ->
    @selected = null

  parse: (resp, xhr) ->
    return resp

  getSelected: ->
    if @selected
      @selected

  setSelected: (param) ->
    @each( (param) ->
      if param.get("selected") == true
        param.set( selected: false )
    )
    if @selected
      @selected.set( selected: false )
    param.set( selected: true )
    @selected = param

  removeSelected: (param) ->
    @each( (param) ->
      param.set( selected: false )
    )

    @selected = null

  getCategories: ->
    categoryNames = []
    @forEach( (param) ->
      if param.get("category")
        categoryNames.push( param.get("category") )
    )
    categoryNames = _.uniq(categoryNames)
    categoryNames = categoryNames.sort()
    categories = []
    if categoryNames.length > 0
      _.map(categoryNames, (categoryName) ->
        category =
          name: categoryName
          value: categoryName.toLowerCase().replace(" ", "_")
        categories.push(category)
      )
    return categories

