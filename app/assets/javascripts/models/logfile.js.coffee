class Cds.Models.Logfile extends Backbone.Model

  initialize: (props) ->
    @logfiles = new Cds.Collections.Logfiles()
    _.bindAll(this)