class Cds.Views.Alert extends Backbone.View

  initialize: () ->
    $flash = $(".flash")
    $flash.empty()
    $flash.html(@createAlert())
    setTimeout(@resetFlash, 3000)
    _.bindAll(@)

  render: () ->
    this

  createAlert: () ->
    flash = """ <div class="alert fade in alert-#{@options.status}">
                  <button class="close" data-dismiss="alert">×</button>#{@options.msg}
                </div>
            """

  resetFlash: () ->
    #close alert messages from rails
    $(".alert").fadeOut("slow")
    $(".flash").empty()
