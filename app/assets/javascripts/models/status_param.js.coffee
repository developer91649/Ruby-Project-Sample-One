class Cds.Models.StatusParam extends Cds.Models.HealthParam

  initialize: () ->
    @statusparams = new Cds.Collections.StatusParams()
    @saveCategoryValue()
    _.bindAll(this)