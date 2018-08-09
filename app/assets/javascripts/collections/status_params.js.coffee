class Cds.Collections.StatusParams extends Cds.Collections.HealthParams
  url: '/api/statusmonitoring'
  model: Cds.Models.StatusParam

  parse: (resp, xhr) ->
    return resp
