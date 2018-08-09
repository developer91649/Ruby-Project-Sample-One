class Cds.Views.LocomotiveFaultSummary extends Backbone.View
  # Set in initalize to default of Show All or to user's default
  prefSeverityFilter = undefined

  template: JST['locomotives/locomotive_fault_summary']
  events:
    "click .refresh-page": "render"
    "change .severity-filter select": "reRenderWithFilter"

  initialize: ->
    @user = @options.user
    @getSeverityPref()

  render : ->
    @initFaultSummaryLoad()
    $(@el).html(@template(locomotive: @model, user: @user))
    @appendQuickview()
    this

  getSeverityPref: ->
    @prefSeverityFilter = @user.get("pref_fault_severity_filter")
    if @prefSeverityFilter == null
      @prefSeverityFilter = "Show All"

  appendQuickview: ->
    locomotiveQuickview = new Cds.Views.LocomotiveQuickview(
      model: @model
      user: @user
    )
    @$('.quickview-placeholder').append(locomotiveQuickview.render().el)
    @$('#locomotive-detail-link').parent().addClass('active')

  # when the filter is changed, re-render the whole view, but save the chosen filter
  reRenderWithFilter: ->
    choice = @$(".severity-filter select").find(":selected").text()
    @prefSeverityFilter = choice
    @render()

  addSeverityFilter: ->
    self = @
    severityEls =
      """
      <div class="severity-filter">
        <select class="form-control">
          <option value="Show All">Show All</option>
          <option value="Critical">Critical</option>
          <option value="Critical & Warning">Critical & Warning</option>
          <option value=">60sec Alerts">>60sec Alerts</option>
        </select>
      </div>
      """
    @$(".summary-filter-wrap").prepend(severityEls)
    @$(".severity-filter option").each( () ->
      if $(@).text() == self.prefSeverityFilter
        $(@).parent("select").val($(@).text())
    )

  initFaultSummaryLoad: () ->
    if @prefSeverityFilter == "Critical & Warning"
      faults = @model.faultSummaryWarningCritical
    else if @prefSeverityFilter == "Critical"
      faults = @model.faultSummaryCritical
    else if @prefSeverityFilter == ">60sec Alerts"
      faults = @model.faultSummaryMinute
    else
      faults = @model.faultSummary
    faults.fetch(
      success: (response) =>
        @initFaultArchiveLoad()
        @createFaults(response, @model, "summary")
    )

  createFaults: (faults, locomotive, type) ->
    faultEls = []
    faults.each( (fault) =>
      if !window.fault_consoled
        window.fault_consoled = true
      view = new Cds.Views.Fault(
        model: fault,
        locomotive: locomotive
        user: @user
      )
      faultEls.push(view.render().el)
    )
    @$('.fault-summary-table tbody').append(faultEls)
    @$(".table-loading-#{type}").hide()
    @addDataTables()

  initFaultArchiveLoad: () ->
    switch @prefSeverityFilter
      when "Critical & Warning" then faults = @model.faultArchiveWarningCritical
      when "Critical" then faults = @model.faultArchiveCritical
      when ">60sec Alerts" then faults = @model.faultArchiveMinute
      else faults = @model.faultArchive

    faults.fetch(
      success: (response) => @createArchiveFaults(response, @model, "archive")
    )

  createArchiveFaults: (faults, locomotive, type) ->
    faultEls = []
    mobile = (($(window).width() < 481 or $('html.force-mobile').length > 0) and $('html.force-desktop').length == 0)
    faults.each( (fault, i) =>
      return if i > 99 and mobile
      return if i > 999
      view = new Cds.Views.Fault(
        model: fault,
        locomotive: locomotive
        user: @user
      )
      faultEls.push(view.render().el)
    )
    @$('.fault-archive-table tbody').append(faultEls)
    @$(".table-loading-#{type}").hide()
    @addInvisibleDataTables()
    @createFilters()

  addInvisibleDataTables: () ->
    that = @
    @archiveTable = @$(".fault-archive-table").dataTable(
      "oLanguage":
        "sSearch": "Search:"
        "sEmptyTable": "There are no faults in the archive."
      "bLengthChange": false
      "bPaginate": false
      "bAutoWidth": false
      "bInfo": false
      "aaSorting": [[ 5, "desc" ]]
      aoColumns: [
        null,
        null,
        bSortable: false,
        null,
        null,
          "sType": "data-utc",
        bSortable: false
      ]
    )
    @summaryTable.bind('sort', (e, dataTables) =>
      $sortedBy = $(e.target).find("th[aria-sort]")
      sortedByIndex = $sortedBy.index()
      longSortDirection = $sortedBy.attr("aria-sort")
      if longSortDirection is "ascending"
        sortDirection = "asc"
      else
        sortDirection = "desc"
      @archiveTable.fnSort( [ [sortedByIndex,sortDirection] ] )
    )

   fnCreateSelect: (aData) ->
    options = []
    iLen = aData.length
    i = 0
    while i < iLen
      options.push("<option value='#{aData[i]}'>#{aData[i]}</option>")
      i++
    return options

  createFilterSelect: (table, filter, i) ->
    filter.innerHTML = @fnCreateSelect(table.fnGetColumnData(i))
    $("select", filter).change ->
      table.fnFilter $(filter).val(), i

  addDataTables: () ->
    #"sType": "title-numeric",
    @summaryTable = @$(".fault-summary-table").dataTable(
      "oLanguage":
        "sSearch": "Search:"
        "sEmptyTable": "There are no active faults for this locomotive."
      "bLengthChange": false
      "bPaginate": false
      "bAutoWidth": false
      "bInfo": false
      "aaSorting": [[ 5, "desc" ]]
      aoColumns: [
        null,
        null,
        bSortable: false,
        null,
        null,
          "sType": "data-utc",
        bSortable: false
      ]
    )

  createFilters: ->
    that = @
    that.$(".loading-inline").fadeOut()
    filters =
      """
      <div class="summary-filters">
        <ul>
          <li class="filter filter-system"><span></span></li>
          <li class="filter filter-severity"><span>Severity</span></li>
          <li class="filter filter-map"><span>Map</span></li>
          <li class="filter filter-code"><span></span></li>
          <li class="filter filter-name"><span></span></li>
          <li class="refresh-icon refresh-page btn btn-default small">Refresh <span class="glyphicon glyphicon-refresh"></span></li>
        </ul>
      </div>
      """
    @addSeverityFilter()
    @$(".summary-filter-wrap").append(filters)
    # Add a select menu for each TH element in the table footer
    @$(".summary-filters li").each (i) ->
      if $(@).hasClass("filter-system")
        summaryOptions = that.fnCreateSelect(that.summaryTable.fnGetColumnData(i))
        archiveOptions = that.fnCreateSelect(that.archiveTable.fnGetColumnData(i))
        all_options = _.union(summaryOptions, archiveOptions)
        select = "<select class='form-control'></option>"
        select += all_options
        select += "</select>"
        $("span", this).after(select)
        $("select", this).change ->
          that.summaryTable.fnFilter $(this).val(), i
          that.archiveTable.fnFilter $(this).val(), i

      if $(@).hasClass("filter-severity")
        $(@).remove()

      if $(@).hasClass("filter-map")
        $(@).remove()

      if $(@).hasClass("filter-code")
        summaryOptions = that.fnCreateSelect(that.summaryTable.fnGetColumnData(i))
        archiveOptions = that.fnCreateSelect(that.archiveTable.fnGetColumnData(i))
        all_options = _.union(summaryOptions, archiveOptions)
        select = "<select class='form-control'></option>"
        select += all_options
        select += "</select>"
        $("span", this).after(select)

        $("select", this).change ->
          value = $(this).val()
          # match exact values by adding spaces
          value = "^\\s*#{value}\\s*$"
          that.summaryTable.fnFilter( value, i, true, false )
          that.archiveTable.fnFilter( value, i, true, false )

      if $(@).hasClass("filter-name")
        summaryOptions = that.fnCreateSelect(that.summaryTable.fnGetColumnData(i))
        archiveOptions = that.fnCreateSelect(that.archiveTable.fnGetColumnData(i))
        all_options = _.union(summaryOptions, archiveOptions)
        select = "<select class='form-control'></option>"
        select += all_options
        select += "</select>"
        $("span", this).after(select)
        $("select", this).change ->
          that.summaryTable.fnFilter( $(this).val(), i )
          that.archiveTable.fnFilter( $(this).val(), i )


