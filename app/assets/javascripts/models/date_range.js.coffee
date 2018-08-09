class Cds.Models.DateRange extends Backbone.Model
  # Properties:
  # 
  # from_date_raw
  # to_date_raw
  # from_display
  # to_display

  initialize: () ->
    @bind("change:from_date_raw", @createFromDisplayDate)
    @bind("change:to_date_raw", @createToDisplayDate)

  createFromDisplayDate: (date_key) ->
    key_raw = @get("from_date_raw")
    @set( from_display: key_raw.format("MMMM D, YYYY") )
    @set( from_time: key_raw.format("HH:mm:ss") )
    @set( url_from: encodeURIComponent(key_raw.format()))

  createToDisplayDate: (date_key) ->
    key_raw = @get("to_date_raw")
    @set( to_display: key_raw.format("MMMM D, YYYY") )
    @set( to_time: key_raw.format("HH:mm:ss") )
    @set( url_to: encodeURIComponent(key_raw.format()))
