//= require active_admin/base
sendSortRequestOfModel = (model_name) ->
  formData = $("##{model_name} tbody").sortable('serialize')
  formData += '&' + $('meta[name=csrf-param]').attr('content') +
    '=' + encodeURIComponent($('meta[name=csrf-token]').attr('content'))
  $.ajax
    type: 'post'
    data: formData
    dataType: 'script'
    url: '/admin/' + model_name + '/sort'


jQuery ($) ->
  if $('body.admin_cds_account_resources.index').length
    $( '#cds_account_resources tbody' ).disableSelection()
    $('#cds_account_resources tr').css("cursor": "move")
    $( '#cds_account_resources tbody' ).sortable
      axis: 'y'
      cursor: 'move'
      update: (event, ui) ->
        sendSortRequestOfModel('cds_account_resources')

  if $('body.admin_monitoring_params.index').length
    $( '#monitoring_params tbody' ).disableSelection()
    $('#monitoring_params tr').css("cursor": "move")
    $( '#monitoring_params tbody' ).sortable
      axis: 'y'
      cursor: 'move'
      update: (event, ui) ->
        sendSortRequestOfModel('monitoring_params')