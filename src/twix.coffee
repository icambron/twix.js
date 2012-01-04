if typeof module != "undefined"
  moment = require('moment')
else moment = window.moment

#ensure we can find moment
if typeof moment == "undefined"
  throw "Can't find moment"

class Twix
  constructor: (start, end, options) -> 
    @start = moment start
    @end = moment end
    @options = options || {}

  toString: ->
    formatters = [
      {
        name: "year", 
        fn: (date) -> date.format "YYYY"
        pre: ", "
        slot: 2
        #only show the year if it varies, or it isn't this year
        skip: @start.year() == moment().year() && @start.year() == @end.year()
      }
      {
        name: "month"
        fn: (date) -> date.format "MMM"
        slot: 0
        skip: !@options.allDay
        pre: " "
      }
      {
        name: "date"
        fn: (date) -> date.format "D"
        slot: 1
        skip: !@options.allDay,
        pre: " "
      }
      {
        name: "month and date"
        fn: (date) -> date.format "MMM D"
        slot: 0
        skip: @options.allDay
        pre: " "
      }
      {
        name: "meridian", 
        fn: (t) => t.format("A")
        slot: 4
        skip: @options.twentyFour || @options.allDay
        pre: " "
      }
      {
        name: "time",
        fn: (date) -> if date.minutes() == 0 then date.format("h") else date.format("h:mm")
        skip: @options.allDay
        pre: ", "
        slot: 3
      }
    ]

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

    process format for format in formatters when format.skip isnt true

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

if typeof module != "undefined"
  module.exports = Twix
else
  window.Twix = Twix