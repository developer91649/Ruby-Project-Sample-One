class Cds.Models.Alarm extends Backbone.Model
  urlRoot: "/api/alarms/"

  initialize: () ->
    @url = "#{@urlRoot}#{@id}"
    _.bindAll(@)

  parse: (response)->
    # Transform fault array into CDS fault model
    response.fault = new Cds.Models.Fault(response.fault)
    response