class Cds.Collections.Faults extends Backbone.Collection
  model: Cds.Models.Fault
  url: '/api/faults/'

  initialize: () ->