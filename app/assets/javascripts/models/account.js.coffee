class Cds.Models.Account extends Backbone.Model
  urlRoot: '/api/accounts/'

  getLocoDataViewsConfig: (locomotive) ->
    views = Cds.accountConfig.getLocoDataViewsConfig(@get("liis_id"), locomotive)
  getEngineDataViewsConfig: ->
    views = Cds.accountConfig.getEngineDataViewsConfig(@get("liis_id"))
