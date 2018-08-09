class Cds.Collections.Users extends Backbone.Collection
  url: "/users"
  model: Cds.Models.User

  parse: (resp, xhr) ->
    return resp
