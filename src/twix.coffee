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

  # -- INFORMATIONAL --
  isSame: (period) -> @start.isSame @end, period

  length: (period) -> @_trueEnd().add(1, "millisecond").diff @_trueStart(), period

  count: (period) ->
    start = @start.clone().startOf period
    end = @end.clone().startOf period
    end.diff(start, period) + 1

  countInner: (period) ->
    [start, end] = @_inner period

    return 0 if start >= end
    end.diff(start, period)

  iterate: (period, minHours) ->
    start = @start.clone().startOf period
    end = @end.clone().startOf period
    hasNext = => start <= end && (!minHours || start.valueOf() != end.valueOf() || @end.hours() > minHours || @allDay)
    @_iterateHelper period, start, hasNext

  iterateInner: (period) ->
    [start, end] = @_inner period
    hasNext = -> start < end

    @_iterateHelper period, start, hasNext

  humanizeLength: ->
    if @allDay
      if @isSame "day"
        "all day"
      else
        @start.from(@end.clone().add('days', 1), true)
    else
      @start.from(@end, true)

  asDuration: (units) ->
    diff = @end.diff @start
    moment.duration(diff)

  isPast: ->
    if @allDay
      @end.clone().endOf("day") < moment()
    else
      @end < moment()

  isFuture: ->
    if @allDay
      @start.clone().startOf("day") > moment()
    else
      @start > moment()

  isCurrent: -> !@isPast() && !@isFuture()

  contains: (mom) ->
    mom = moment mom
    @_trueStart() <= mom && @_trueEnd() >= mom

  # -- WORK WITH MULTIPLE RANGES --
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

  equals: (other) ->
    (other instanceof Twix) &&
      @allDay == other.allDay &&
      @start.valueOf() == other.start.valueOf() &&
      @end.valueOf() == other.end.valueOf()

  # -- FORMATING --
  toString: -> "{start: #{@start.format()}, end: #{@end.format()}, allDay: #{@allDay ? "true" : "false"}}"

  simpleFormat: (momentOpts, inopts) ->
    options = allDay: "(all day)"

    extend options, (inopts || {})

    s = "#{@start.format(momentOpts)} - #{@end.format(momentOpts)}"
    s += " #{options.allDay}" if @allDay && options.allDay
    s

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

    needDate = options.showDate || (!@isSame("day") && !goesIntoTheMorning)

    if @allDay && @isSame("day") && (!options.showDate || options.explicitAllDay)
      fs.push
        name: "all day simple"
        fn: -> options.allDay
        slot: 0
        pre: " "

    if needDate && (!options.implicitYear || @start.year() != moment().year() || !@isSame("year"))
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
        fn: (date) -> date.format options.monthFormat
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

  # -- DEPRECATED METHODS --
  sameDay: -> @isSame "day"
  sameYear: -> @isSame "year"
  countDays: -> @countOuter "days"
  daysIn: (minHours) -> @iterate 'days', minHours
  past: -> @isPast()
  duration: -> @humanizeLength()

  # -- INTERNAL
  _trueStart: -> if @allDay then @start.clone().startOf("day") else @start
  _trueEnd: -> if @allDay then @end.clone().endOf("day") else @end

  _iterateHelper: (period, iter, hasNext) ->
    next: =>
      unless hasNext()
        null
      else
        val = iter.clone()
        iter.add(period, 1)
        val
    hasNext: hasNext

  _inner: (period) ->
    start = @start.clone().startOf(period)
    end = @end.clone().startOf(period)
    (if @allDay then end else start).add(1, period)
    [start, end]

extend = (first, second) ->
  for attr of second
    first[attr] = second[attr] unless typeof second[attr] == "undefined"

if typeof module != "undefined"
  module.exports = Twix
else
  window.Twix = Twix

moment.twix = -> new Twix(arguments...)
moment.fn.twix = -> new Twix(this, arguments...)
moment.fn.forDuration = (duration, allDay) -> new Twix(this, this.clone().add(duration), allDay)
moment.duration.fn.afterMoment = (startingTime, allDay) -> new Twix(startingTime, moment(startingTime).clone().add(this), allDay)
moment.duration.fn.beforeMoment = (startingTime, allDay) -> new Twix(moment(startingTime).clone().subtract(this), startingTime, allDay)
