class Cds.Views.KnowledgebaseList extends Backbone.View
  template: JST['faults/knowledgebase_list']
  events:
    "click tbody tr": "navigateToDetail"

  initialize: ->
    _.bindAll(@)

  render: ->
    $(@el).html(@template(faults: @collection.toJSON() ))
    _.defer( () =>
      @addDataTables()
    , this)
    this

  fnCreateSelect: (aData) ->
    r = "<select><option value=\"\"></option>"
    iLen = aData.length
    i = 0
    while i < iLen
      r += "<option value='#{aData[i]}'>#{aData[i]}</option>"
      i++
    r + "</select>"

  addDataTables: () ->
    that = @
    @oTable = @$("#kb-list").dataTable(
      oLanguage:
        sSearch: "<span>Search:</span>"
      iDisplayLength: 50
      sPaginationType: "full_numbers"
      aoColumns: [
        null,
        null,
        bSortable: false
      ]
    )
    filters = """
              <div class="kb-filters">
                <ul>Filter by:
                    <li class="article_title">&nbsp;</li>
                    <li class="filter-code">&nbsp;</li>
                    <li class="filter system"><span>System</span></li>
                </ul>
              </div>
              """
    @$("#kb-list_length").after(filters)
    # Add a select menu for each TH element in the table footer
    @$(".kb-filters li").each (i) ->
      if $(@).hasClass("system")
        @innerHTML = that.fnCreateSelect(that.oTable.fnGetColumnData(i))
        $("select", this).change ->
          that.oTable.fnFilter $(this).val(), i

    # hide .related_faults col, filter doesn't work without it. fix this later
    @$(".article_title").hide()

  navigateToDetail: (e) ->
    fault_id = $(e.target).parent("tr").attr("data-id")
    Backbone.history.navigate("/kb/#{fault_id}", true)
