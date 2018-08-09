Date.prototype.stdTimezoneOffset = ->
  jan = new Date(@getFullYear(), 0, 1)
  jul = new Date(@getFullYear(), 6, 1)
  return Math.max(jan.getTimezoneOffset(), jul.getTimezoneOffset())
Date.prototype.dst = ->
  return @getTimezoneOffset() < @stdTimezoneOffset()


Cds.time = do ->

  checkforDST = (time) ->
    time = new Date(time)
    return time.dst()

  addDaylightSavings = (time) ->
    observeDST = checkforDST(time)
    if observeDST
      return time.add("hours", 1)
    else
      return time

  convertToPrefTimzone = (user, time) ->
    timezonePref = user.get("pref_timezone")
    # default to eastern time
    if timezonePref == ""
      timezonePref = "(GMT-05:00) Eastern Time (US & Canada)"
    # (GMT+10:00) Brisbane
    findPrefOffset = /\(GMT([^\)]+)\)/
    prefOffset = findPrefOffset.exec(timezonePref)[1]
    prefTime = moment(time).zone(prefOffset)

  # takes utc time
  formatTime = (time) ->
    time.format("YYYY-MM-DD HH:mm:ss")

  convertTimeByPref =
    "UTC":
      time: (opts) ->
        utcTime = moment(opts.time).utc()
        formatTime(utcTime)
    "Preference":
      time: (opts) ->
        prefTime = convertToPrefTimzone(opts.user, opts.time)
        if opts.user.get("pref_daylight_savings")
          prefTime = addDaylightSavings(prefTime)
        prefTime = formatTime(prefTime)
    "Locomotive":
      time: (opts) ->
        locomotive = opts.locomotive
        locoOffset = locomotive.get("time_offset")
        if locoOffset == null
          locoOffset = "+00:00"
        locoOffset = locoOffset.replace(/:/g, "")
        time = locomotive.get("time_utc_gps")
        if time is null
          time = locomotive.get("time_utc")
        if opts.time?
          time = opts.time
        locoTime = moment(time).zone(locoOffset)
        locoTime = formatTime(locoTime)

  return {

    getTimeUTC: (opts={})->
      convertTimeByPref["UTC"].time(opts)

    # takes user, time, locomotive
    getTimeByUserPref: (opts={}) ->
      convertTimeByPref[opts.user.get("pref_time_display")].time(opts)

    getUserPrefTime: (opts={}) ->
      convertTimeByPref["Preference"].time(opts)

    getLocoTime: (opts={}) ->
      convertTimeByPref["Locomotive"].time(opts)

    getAllTimes: (opts={}) ->
      times =
        "utc": @getTimeUTC(opts)
        "preference": @getUserPrefTime(opts)
        "locomotive": @getLocoTime(opts)

    tzAbbr: (dateInput) ->
      dateObject = dateInput or new Date()
      dateString = dateObject + ""

      # Works for the majority of modern browsers

      # IE outputs date strings in a different format:
      tzAbbr = (dateString.match(/\(([^\)]+)\)$/) or dateString.match(/([A-Z]+) [\d]{4}$/))

      # Old Firefox uses the long timezone name (e.g., "Central
      # Daylight Time" instead of "CDT")
      tzAbbr = tzAbbr[1].match(/[A-Z]/g).join("")  if tzAbbr

      # Uncomment these lines to return a GMT offset for browsers
      # that don't include the user's zone abbreviation (e.g.,
      # "GMT-0500".) I prefer to have `null` in this case, but
      # you may not!
      # First seen on: http://stackoverflow.com/a/12496442
      if !tzAbbr && /(GMT\W*\d{4})/.test(dateString)
        return RegExp.$1
      tzAbbr

  # moment dates
  getDateSelectionByDays: (start, end) ->
    chosenDays = []
    numberOfHours = end.diff(start, 'hours')
    numberOfDays = end.diff(start, 'days')
    # hack to account for some sort of timezone diff, fix when addressing timezones
    if numberOfHours > 21 and numberOfHours < 24 then numberOfDays = 1
    counterDate = start.clone()
    i = 0
    while i <= numberOfDays
      chosenDays.push( [ counterDate.format("YYYY") * 1, counterDate.format("M") * 1, counterDate.format("D") * 1 ] )
      counterDate = counterDate.add('days', 1)
      i++
    chosenDays

  }