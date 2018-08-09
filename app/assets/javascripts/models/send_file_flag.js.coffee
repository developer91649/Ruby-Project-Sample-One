class Cds.Models.SendFileFlag extends Backbone.Model

  isNew: ->
    @enum_value == null

  url: ->
    base = _.result(this, "urlRoot") or _.result(@collection, "url") or urlError()
    base + ((if base.charAt(base.length - 1) is "/" then "" else "/")) + encodeURIComponent(@get("enum_value"))

  initialize: (props) ->
    @sendFileFlags = new Cds.Collections.Logfiles()
    _.bindAll(this)