class Cds.Views.ResourcesList extends Backbone.View
  events:
    "click .resource-cat-wrap a": "toggleListDisplay"

  initialize: ->
    _.bindAll(@)

  render: ->
    $(@el).addClass("resource-links-super-wrap")
    @addResources()
    this

  toggleListDisplay: (e) ->
    $(e.target).toggleClass("close-resource-cat", "open-resource-cat")
    $(e.target).parent("h4").next(".resource-links-wrap").find("ul").slideToggle()

  getCategories: (resources) ->
    categories = []
    resources.each( (resource) ->
      if resource.get("category_name")
        categories.push( resource.get("category_name") )
    )
    categories = _.uniq(categories)

  formatCategories: (categories) ->
    categoryDOM = ""
    _.each(categories, (category) =>
      catAttr = category.toLowerCase().replace(" ", "_")
      categoryDOM += """
                    <div class='resource-cat-wrap'>
                      <h4><a class='view'>#{category}</a></h4>
                      <div class='resource-links-wrap'>
                        <ul style='display:none;' data-category='#{catAttr}'></ul>
                      </div>
                    </div>
                    """
    )
    categoryDOM

  addResources: ->
    categories = @getCategories(@collection)
    if categories.length > 0
      categoryDOM = @formatCategories(categories)
      $(@el).prepend(categoryDOM)
      @collection.each( (resource) =>
        el = "<li>"
        if resource.get("file_file_name")?
          link = resource.get("file_url")
          linkClass = "pdf"
        else if resource.get("link_url")?
          link = resource.get("link_url")
          linkClass = "outgoing"
        el += "<a class='#{linkClass}' href='#{link}'>#{resource.get("title")}</a></li>"
        catAttr = resource.get("category_name").toLowerCase().replace(" ", "_")
        $(@el).find("ul[data-category='#{catAttr}']").append(el)
      )