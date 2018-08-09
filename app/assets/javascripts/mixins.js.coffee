Cds.Mixins = {}
Cds.Mixins.UI = {

  toggleWrap: (e) ->
    $tgt = $(e.currentTarget)
    elToToggle = $tgt.attr('data-toggle')
    canvas = $("##{elToToggle}-wrap")
    if $(canvas).is(':visible')
#      $(e.target).html('<span class="glyphicon glyphicon-menu-up" aria-hidden="true"></span><span class="glyphicon glyphicon-menu-down" aria-hidden="true"></span>')
      $(canvas).slideUp()
    else
#      $(e.target).html('<span class="glyphicon glyphicon-menu-up" aria-hidden="true"></span><span class="glyphicon glyphicon-menu-down" aria-hidden="true"></span>')
      $(canvas).slideDown()

  toggleMap: (e) ->
    $tgt = $(e.currentTarget)
    elToToggle = $tgt.attr('data-toggle')
    canvas = $("##{elToToggle}-wrap")
    if $(canvas).is(':visible')
#      $(e.target).html('<span class="glyphicon glyphicon-menu-up" aria-hidden="true"></span><span class="glyphicon glyphicon-menu-down" aria-hidden="true"></span>')
      $(canvas).slideUp()
      @trigger('collapse')
    else
#      $(e.target).html('<span class="glyphicon glyphicon-menu-up" aria-hidden="true"></span><span class="glyphicon glyphicon-menu-down" aria-hidden="true"></span>')
      $(canvas).slideDown()
      @centerMap()
      @trigger('expand')


}
