###*
# Block on locomotive detail page
# @class
# @param config Display options
# @param {boolean} show_title - Displays title of param from feed via CMS
# @param {number} columns - Number of columns to take up in grid on LD page
# @param {string} [link_url] - Link at bottom of block
# @param {string} [link_text] - Link text for the link at the bottom of the block
# @param {string} [units_suffix] - Text added to the end of the units from feed via CMS
###
class Cds.Views.FeaturedBasic extends Backbone.View
  tagName: "li"
  className: "featured-param"
  events:
    "click": "paramLink"

  initialize: ->
    # engine data contains an array of rows, locomotive does not.
    # @model from engine_data example: {id: 1, title: "", units: "RPM", value: 0}
    # already json
    if @model instanceof Backbone.Model
      @param = @model.toJSON()
      # Would this work? Hard to test
      # @options.model.on("change:value", @test)
    else
      @param = @model

  render: ->
    if @options.config.show_sub_title is true
      $(@el).html("<h4>#{@param.value}</h4>")
      $(@el).append("<h6>#{@param.units} TO EMPTY</h6>")
      @addLayoutClasses()
    else
      $(@el).html("<h4>#{@param.value}<span>#{@param.units}</span></h4>")
      @addLayoutClasses()
      if @options.config.show_title is true
        $(@el).prepend("<h5>#{@param.title}</h5>")
      # add special class if title should not be shown and there is no link
      if @options.config.show_title is false and !@options.config.link_url?
        $(@el).find("h4").addClass("notitle")
      if @options.config.link_url?
        @addLink()
      if @options.config.units_suffix?
        unitText = $(@el).find("h4 span").text()
        $(@el).find("h4 span").html("#{unitText} <em>#{@options.config.units_suffix}</em>")

    this

  addLayoutClasses: ->
    if @options.config.custom_class?
      $(@el).addClass(@options.config.custom_class)
    $(@el).addClass("columns#{@options.config.columns} #{@options.config.type}")
    if @options.config.classes?
      $(@el).addClass(@options.config.classes)

  addLink: ->
    $(@el).addClass("link").attr("data-link", @options.config.link_url)
    $(@el).append("<h6>#{@options.config.link_text}</h6>")

  paramLink: (e) ->
    link = $(e.target).parents(".featured-param").attr("data-link")
    if link?
      Backbone.history.navigate(link, true)
