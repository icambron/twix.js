if typeof module != "undefined"
  moment = require('moment')
else moment = window.moment

#ensure we can find moment
if typeof moment == "undefined"
  throw "Can't find moment"

class Twix
  constructor: (start, end, allDay) -> 
    @start = moment start
    @end = moment end
    @allDay = allDay

  sameDay: ->
    @start.year() == @end.year() &&
    @start.month() == @end.month() &&
    @start.date() == @end.date()

  sameYear: ->
    @start.year() == @end.year()

  format: (inopts) ->
    options =
      groupMeridiems: true
      spaceBeforeMeridiem: true
      showDate: true
      twentyFourHour: false
      implicitMinutes: true

      yearFormat: "YYYY"
      monthFormat: "MMM"
      dayFormat: "D"
      meridiemFormat: "A"
      hourFormat: "h"
      minuteFormat: "mm"
      allDay: "All day"

    extend options, (inopts || {})

    fs = []

    options.hourFormat = options.hourFormat.replace("h", "H") if options.twentyFourHour
    needDate = options.showDate || !@sameDay()

    if @allDay && @sameDay() && !options.showDate
      fs.push
        name: "all day simple"
        fn: -> options.allDay
        slot: 0
        pre: " "

    if needDate && (@start.year() != moment().year() || !@sameYear())
      fs.push
        name: "year", 
        fn: (date) -> date.format options.yearFormat
        pre: ", "
        slot: 3

    if !@allDay && needDate
      fs.push
        name: "all day month"
        fn: (date) -> date.format "#{options.monthFormat} #{options.dayFormat}"
        slot: 1
        pre: " "
        
    if @allDay && needDate
      fs.push
        name: "month"
        fn: (date) -> date.format "MMM"
        slot: 1
        pre: " "

    if @allDay && needDate
      fs.push
        name: "date"
        fn: (date) -> date.format options.dayFormat
        slot: 2
        pre: " "

    if options.groupMeridiems && !options.twentyFourHour && !@allDay
      fs.push
        name: "meridiem", 
        fn: (t) => t.format options.meridiemFormat
        slot: 5
        pre: if options.spaceBeforeMeridiem then " " else ""

    if !@allDay
      fs.push
        name: "time",
        fn: (date) -> 
          if date.minutes() == 0 && options.implicitMinutes
            date.format options.hourFormat 
          else
            str = date.format "#{options.hourFormat}:#{options.minuteFormat}"
            if !options.groupMeridiems && !options.twentyFourHours
              str += " " if options.spaceBeforeMeridiem
              str += date.format options.meridiemFormat
            str
        pre: ", "
        slot: 4

    start_bucket = []
    end_bucket = []
    common_bucket = []
    together = true

    process = (format) =>
      start_str = format.fn @start
      end_str = format.fn @end

      start_group = {format: format, value: -> start_str}
     
      if end_str == start_str && together
        common_bucket.push start_group
      else
        if together
          together = false
          common_bucket.push {format: {slot: format.slot, pre: ""}, value: -> "#{fold start_bucket} -#{fold end_bucket, true}"}

        start_bucket.push start_group
        end_bucket.push {format: format, value: -> end_str}

    process format for format in fs when format.skip isnt true

    global_first = true
    fold = (array, skip_pre) =>
      local_first = true
      str = ""
      for section in array.sort((a, b) -> a.format.slot - b.format.slot)

        unless global_first
          if local_first && skip_pre
            str += " "
          else
            str += section.format.pre

        str += section.value()
      
        global_first = false
        local_first = false
      str

    fold common_bucket  

extend = (first, second) ->
  for attr of second
    first[attr] = second[attr] unless typeof second[attr] == "undefined"
  
if typeof module != "undefined"
  module.exports = Twix
else
  window.Twix = Twix