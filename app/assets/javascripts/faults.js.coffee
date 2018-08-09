$ ->
  $('.fault-notification-list li:odd').addClass("odd")
  $('.fault-notification-list').easyListSplitter(
    colNumber: 3
  )
  $('.fault-notification-list:eq(0)').addClass("one-third alpha")
  $('.fault-notification-list:eq(1)').addClass("one-third")
  $('.fault-notification-list:eq(2)').addClass("one-third omega")


  $('input.update-subscription').change (e) ->
    $.ajax
      url: $(@).val()
      type: "POST"
      data:
        _method: "PUT"
