# move into a collection?
Cds.charts = do ->

  dateOptions = [
    text: "1 Day"
    hours: 24
  ,
    text: "3 Days"
    hours: 72
  ,
    text: "1 Week"
    hours: 168
  ]

  return {

    getDateOptions: () ->
      dateOptions

  }