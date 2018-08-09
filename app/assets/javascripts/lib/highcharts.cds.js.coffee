((H) ->

  ###
  Mark points

  @param {Boolean} mark
  ###
  H.Point.prototype.mark = (mark)->
    marker = @marker || {}
    if (mark)
      @series.chart.addOrderedMark()
      marker.id = @series.chart.selectedPointCount
    else
      marker.id = null
    @marker = marker

  ###
  Add an ordered mark
  ###
  H.Chart.prototype.addOrderedMark = ->
    @selectedPointCount++

  ###
  Select points and display their order

  @param {Boolean} select
  ###
  H.Point.prototype.flag = (flag)->
    if (flag)
      selectedPointCount = @series.chart.selectedPointCount
      @update
        dataLabels:
          backgroundColor: @series.color
          color: 'white'
          borderColor: 'white'
          enabled: true
          format: "#{selectedPointCount+1}"
          padding: 5
          shadow: false
          style:
            fontWeight: 'bold'
    else
      @update
        dataLabels: { enabled: false }

) @Highcharts