// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require jquery
//= require jquery_ujs
//= require jquery-ui
//= require jquery.columnizer
//= require jquery.plugins
//= require jquery.cookie
//= require tables.jquery.min
//= require fixed-columns.min
//= require jquery.cookie
//= require twitter/bootstrap/bootstrap-button
//= require twitter/bootstrap/bootstrap-modal
//= require twitter/bootstrap/bootstrap-dropdown
//= require twitter/bootstrap/bootstrap-alert
//= require twitter/bootstrap/bootstrap-tooltip
//= require twitter/bootstrap/bootstrap-collapse
//= require_directory .
//= require moment
//= require underscore
//= require layout
//= require backbone
//= require timezones.full.min
//= require bootstrap-timepicker.min
//= require jquery.dataTables.min
//= require jquery.dataTables.plugins
//= require backbone.poller
//= require jquery.lightbox_me
//= require highcharts
//= require ./lib/highcharts.cds.js
//= require ./lib/highcharts.SVGRenderer.js
//= require bootstrap-select.min
//= require dataTables.fixedColumns.min
//= require debug
//= require infobox
//= require markerclusterer
//= require_tree ./cds-app
//= require cds
//= require_tree ../templates
//= require_tree ./models
//= require_tree ./collections
//= require_tree ./views/locomotives
//= require_tree ./views
//= require_tree ./routers

$(document).ready(function() {
    $("#switch_company_btn").click(function() {
        $("#switch-company-modal").modal("show");
    })
})