class Cds.Models.Fault extends Backbone.Model
  urlRoot: "/api/faults/"
  defaults:
    severity: null

  initialize: () ->
    @url = "#{@urlRoot}#{@id}"
    _.bindAll(@)

    # add severity for a fault collection
    @addSeverity()

    # or add severity stuff after fault fetched
    @on("change:severity", @addSeverity)
    @resolutionNotes = new Cds.Collections.ResolutionNotes()
    @resolutionNotes.url = "/faults/#{@id}/resolution_notes"

  addSeverity: () ->
    severity = Cds.faults.getSeverity(@get("severity"))
    @set(severity)

  isCritical: ->
    @get("fault_value") == 1
