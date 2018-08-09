class Cds.Views.Button extends Backbone.View
  className : 'btn btn-default'
  tagName   : 'a'

  # events:
  #   'click #locomotive-detail-nav button': 'navigateInQuickview'
  render: ->
    @$el.html @options.html
    @