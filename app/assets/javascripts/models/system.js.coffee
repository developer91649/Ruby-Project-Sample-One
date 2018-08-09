class Cds.Models.System extends Backbone.Model

  initialize: () ->
    @systems = new Cds.Collections.Systems()
    _.bindAll(this)
