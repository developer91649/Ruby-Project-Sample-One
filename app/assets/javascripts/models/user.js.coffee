class Cds.Models.User extends Backbone.Model

  urlRoot: "/user/current"

  initialize: () ->
    _.bindAll(@)

  parse: (data) ->
    return data

  hasFeatureEnabled: (featureName) ->
  
    _.contains(@get("features"), featureName)

  hasRole: (roleName) ->
    _.contains(@get("role_names"), roleName)
