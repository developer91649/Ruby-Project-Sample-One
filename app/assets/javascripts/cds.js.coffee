# magical fix for backbone caching response and not fetching locos
$.ajaxSetup( cache: false )
window.Cds =
  Models: {}
  Collections: {}
  Views: {}
  Routers: {}
  Globals: {}

  initialize: ->
    new Cds.Routers.Locomotives()
    # fix for IE 9 and below
    unless Modernizr.history
      # initialize router/Backbone.history, but turn off route parsing,
      # since non-window.history parsing will look for a hash, and not finding one,
      # will break.
      # not really in use right now because all links are hardcoded. There is no
      # real root to the url, it changes. So the hash was getting all messed up.
      Backbone.history.start
        silent: true
        hashChange: true
      if window.location.hash? or window.location.hash is ""
        subroute = window.location.hash.replace("#", "/")
        route = window.location.pathname + subroute
      else
        route = window.location.pathname
      Backbone.history.loadUrl route
    else
        Backbone.history.start(pushState: true)

    # extend events for flash messages from backbone
    Dispatcher = _.extend({}, Backbone.Events)

    # make sync work with Rails
    # alias away the sync method
    Backbone._sync = Backbone.sync

    # define a new sync method
    Backbone.sync = (method, model, success, error) ->
      # only need a token for non-get requests
      if method is "create" or method is "update" or method is "delete"
        # grab the token from the meta tag rails embeds
        auth_options = {}
        auth_options[$("meta[name='csrf-param']").attr("content")] = $("meta[name='csrf-token']").attr("content")
        # set it as a model attribute without triggering events
        model.set auth_options,
          silent: true
      # proxy the call to the old sync method
      Backbone._sync method, model, success, error

$(document).ready ->
  setTimeout( () ->
    $(".alert").fadeOut("slow")
  , 3000)
  $('#force-desktop').click (e)->
    e.preventDefault()
    $('html').addClass("force-desktop").removeClass("force-mobile")
    $.cookie('force-version', 'desktop')
  $('#force-mobile').click (e)->
    e.preventDefault()
    $('html').removeClass("force-desktop").addClass("force-mobile")
    $.cookie('force-version', 'mobile')
  # fix for IE console bs
  if !window.console
    window.console =
      log: () ->
  Cds.initialize()
