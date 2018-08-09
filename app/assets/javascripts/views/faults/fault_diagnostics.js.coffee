class Cds.Views.FaultDiagnostics extends Backbone.View
  template: JST['faults/fault_diagnostics']
  events:
    "submit .resolution-notes-form": "submitNote"
    "click .ahs.btn": "openHealthSnapshot"

  initialize: ->
    _.bind(@)
    @user         = @options.user
    @alarm        = @options.alarm
    @fault        = @options.fault
    @locomotive   = @options.loco
    @snapshotTime = null
    @getNotes()

    @snapshotTime = @options.utc_time         if @options.utc_time
    @snapshotTime = @alarm.get("time_utc_on") if @alarm

  render: ->
    @$el.html( @template
      locomotive: @locomotive.toJSON()
      alarm: @alarm
      fault: @fault
      user: @user
    )
    @appendQuickview()
    this

  appendQuickview: ->
    locomotiveQuickview = new Cds.Views.LocomotiveQuickview(
      model: @locomotive
      user: @options.user
    )
    @$('.quickview-placeholder').append(locomotiveQuickview.render().el)
    @$('#locomotive-detail-link').parent().addClass('active')

  appendNoResults: ->
    $(".resolution-notes-entries").append('<p class="no-notes">There are no resolution notes yet.</p>')

  getNotes: () ->
    @fault.resolutionNotes.fetch(
      success: (notes) =>
        if notes.length is 0
          @appendNoResults()
        else
          notes.each( (note) =>
            @appendNote(note)
          )
      error: (response) ->
        $(".resolution-notes-entries").append('<p class="no-notes">Resolution notes are not available at this time.</p>')
    )

  appendNote: (note) ->
    noteDate = Cds.time.getUserPrefTime(
      user: @user
      time: note.get("created_at")
    )
    noteAuthor = note.get("user")
    # if note is from feed, or note has just been created by current user
    if noteAuthor?
      author = "#{noteAuthor.first_name} #{noteAuthor.last_name}"
    else
      author = "#{@user.get("first_name")} #{@user.get("last_name")}"
    noteEl = """
              <div class="resolution-note">
                <h6 class="clearfix">
                  <strong>#{author}</strong>
                  <em>#{noteDate}</em>
                </h6>
                <p>#{note.get("note")}</p>
              </div>
            """
    $(".resolution-notes-entries").append(noteEl)

  clearForm: () ->
    @$("#resolution-note-text").val("")

  submitNote: (e) ->
    e.preventDefault()
    e.stopPropagation()
    user_id = @user.get("id")
    fault_id = @fault.get("id")
    note_text = $(e.target).find("#resolution-note-text").val()
    note = new Cds.Models.ResolutionNote(
      user_id: user_id
      fault_id: fault_id
      note: note_text
    )
    @collection = new Cds.Collections.ResolutionNotes()
    @collection.create note,
      success: (response) =>
        @$(".no-notes").remove()
        @appendNote(response)
        @clearForm()
      error: (response) =>
        $(".resolution-notes-entries").append('<p class="no-notes">There was an error submitting your notes.</p>')

  openHealthSnapshot: (e)->
    e.preventDefault()

    unless @snapshot? and @snapshot.$el.is(":visible")
      viewParams =
        loco  : @locomotive
        fault : @fault
        queryTime: @snapshotTime

      # Get the Target Analysis Params
      @locomotive.getAlarmHealthSnapshots(
        datetime: encodeURIComponent(@snapshotTime)
        fault_id: @fault.id
      )
      
      @snapshot = new Cds.Views.HealthSnapshot(viewParams) # Create a view instance

      $snapshotElement = $(@snapshot.render().el)
      $snapshotElement.appendTo "body"
      $snapshotElement.draggable(handle: ".dialog-header")
      $snapshotElement.position
        my: "center"
        at: "center"
        of: window

      @locomotive.alarmHealthSnapshots.fetch(
        success: (result) => @snapshot.displayData result
      )
