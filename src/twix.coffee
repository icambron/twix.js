if typeof module != "undefined"
  moment = require('moment')
else moment = @moment

#ensure we can find moment
if typeof moment == "undefined"
  throw "Can't find moment"

class Twix
  constructor: (start, end, allDay) ->
    @start = moment start
    @end = moment end
    @allDay = allDay || false

  sameDay: ->
    @start.year() == @end.year() &&
    @start.month() == @end.month() &&
    @start.date() == @end.date()

  sameYear: ->
    @start.year() == @end.year()

  countDays: ->
    startDate = @start.clone().startOf("day")
    endDate = @end.clone().startOf("day")
    endDate.diff(startDate, 'days') + 1

  daysIn: (minHours) ->
    iter = @start.clone().startOf("day")
    endDate = @end.clone().startOf("day")

    hasNext = => iter <= endDate && (!minHours || iter.valueOf() != endDate.valueOf() || @end.hours() > minHours || @allDay)

    next: =>
      unless hasNext()
        null
      else
        val = iter.clone()
        iter.add('days', 1)
        val
    hasNext: hasNext

  duration: ->
    if @allDay
      if @sameDay()
        "all day"
      else
        @start.from(@end.clone().add('days', 1), true)
    else
      @start.from(@end, true)

  past: ->
    if @allDay
      @end.clone().endOf("day") < moment()
    else
      @end < moment()

  overlaps: (other) -> !(@_trueEnd() < other._trueStart() || @_trueStart() > other._trueEnd())

  engulfs: (other) -> @_trueStart() <= other._trueStart() && @_trueEnd() >= other._trueEnd()

  merge: (other) ->
    allDay = @allDay && other.allDay
    if allDay
      newStart = if @start < other.start then @start else other.start
      newEnd = if @end > other.end then @end else other.end
    else
      newStart = if @_trueStart() < other._trueStart() then @_trueStart() else other._trueStart()
      newEnd = if @_trueEnd() > other._trueEnd() then @_trueEnd() else other._trueEnd()

    new Twix(newStart, newEnd, allDay)

  _trueStart: -> if @allDay then @start.clone().startOf("day") else @start
  _trueEnd: -> if @allDay then @end.clone().endOf("day") else @end

  equals: (other) ->
    (other instanceof Twix) &&
      @allDay == other.allDay &&
      @start.valueOf() == other.start.valueOf() &&
      @end.valueOf() == other.end.valueOf()

  format: (inopts) ->
    options =
      groupMeridiems: true
      spaceBeforeMeridiem: true
      showDate: true
      showDayOfWeek: false
      twentyFourHour: false
      implicitMinutes: true
      implicitYear: true
      yearFormat: "YYYY"
      monthFormat: "MMM"
      weekdayFormat: "ddd"
      dayFormat: "D"
      meridiemFormat: "A"
      hourFormat: "h"
      minuteFormat: "mm"
      allDay: "all day"
      explicitAllDay: false
      lastNightEndsAt: 0

    extend options, (inopts || {})

    fs = []

    options.hourFormat = options.hourFormat.replace("h", "H") if options.twentyFourHour

    goesIntoTheMorning =
      options.lastNightEndsAt > 0 &&
      !@allDay &&
      @end.clone().startOf('day').valueOf() == @start.clone().add('days', 1).startOf("day").valueOf() &&
      @start.hours() > 12 &&
      @end.hours() < options.lastNightEndsAt

    needDate = options.showDate || (!@sameDay() && !goesIntoTheMorning)

    if @allDay && @sameDay() && (!options.showDate || options.explicitAllDay)
      fs.push
        name: "all day simple"
        fn: -> options.allDay
        slot: 0
        pre: " "

    if needDate && (!options.implicitYear || @start.year() != moment().year() || !@sameYear())
      fs.push
        name: "year",
        fn: (date) -> date.format options.yearFormat
        pre: ", "
        slot: 4

    if !@allDay && needDate
      fs.push
        name: "all day month"
        fn: (date) -> date.format "#{options.monthFormat} #{options.dayFormat}"
        ignoreEnd: -> goesIntoTheMorning
        slot: 2
        pre: " "

    if @allDay && needDate
      fs.push
        name: "month"
        fn: (date) -> date.format "MMM"
        slot: 2
        pre: " "

    if @allDay && needDate
      fs.push
        name: "date"
        fn: (date) -> date.format options.dayFormat
        slot: 3
        pre: " "

    if needDate && options.showDayOfWeek
      fs.push
        name: "day of week",
        fn: (date) -> date.format options.weekdayFormat
        pre: " "
        slot: 1

    if options.groupMeridiems && !options.twentyFourHour && !@allDay
      fs.push
        name: "meridiem",
        fn: (t) => t.format options.meridiemFormat
        slot: 6
        pre: if options.spaceBeforeMeridiem then " " else ""

    if !@allDay
      fs.push
        name: "time",
        fn: (date) ->
          str = if date.minutes() == 0 && options.implicitMinutes && !options.twentyFourHour
                  date.format options.hourFormat
                else
                  date.format "#{options.hourFormat}:#{options.minuteFormat}"

          if !options.groupMeridiems && !options.twentyFourHour
            str += " " if options.spaceBeforeMeridiem
            str += date.format options.meridiemFormat
          str
        pre: ", "
        slot: 5

    start_bucket = []
    end_bucket = []
    common_bucket = []
    together = true

    process = (format) =>
      start_str = format.fn @start

      end_str = if format.ignoreEnd && format.ignoreEnd()
                  start_str
                else format.fn @end

      start_group = {format: format, value: -> start_str}

      if end_str == start_str && together
        common_bucket.push start_group
      else
        if together
          together = false
          common_bucket.push {format: {slot: format.slot, pre: ""}, value: -> "#{fold start_bucket} -#{fold end_bucket, true}"}

        start_bucket.push start_group
        end_bucket.push {format: format, value: -> end_str}

    process format for format in fs

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
moment.twix = -> new Twix(arguments...)
