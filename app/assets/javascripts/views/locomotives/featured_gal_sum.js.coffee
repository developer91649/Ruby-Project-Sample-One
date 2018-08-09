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
class Cds.Views.FeaturedGalSum extends Backbone.View
  className: "gal-sum-wrap"
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

    this

