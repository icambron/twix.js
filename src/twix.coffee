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
    @langData = @start.lang()
    if @langData._abbr != @end.lang()._abbr
      @end.lang(@langData._abbr)

  @defaults:
    twentyFourHour: false
    allDaySimple:
      fn: (options) -> () -> options.allDay
      slot: 0
      pre: " "
    dayOfWeek:
      fn: (options) -> (date) -> date.format options.weekdayFormat
      slot: 1
      pre: " "
    allDayMonth:
      fn: (options) -> (date) -> date.format "#{options.monthFormat} #{options.dayFormat}"
      slot: 2
      pre: " "
    month:
      fn: (options) -> (date) -> date.format options.monthFormat
      slot: 2
      pre: " "
    date:
      fn: (options) -> (date) -> date.format options.dayFormat
      slot: 3
      pre: " "
    year:
      fn: (options) -> (date) -> date.format options.yearFormat
      slot: 4
      pre: ", "
    time:
      fn: (options) -> (date) ->
        str = if date.minutes() == 0 && options.implicitMinutes && !options.twentyFourHour
                date.format options.hourFormat
              else
                date.format "#{options.hourFormat}:#{options.minuteFormat}"

        if !options.groupMeridiems && !options.twentyFourHour
          str += " " if options.spaceBeforeMeridiem
          str += date.format options.meridiemFormat
        str
      slot: 5
      pre: ", "
    meridiem:
      fn: (options) -> (t) => t.format options.meridiemFormat
      slot: 6
      pre: (options)->
        if options.spaceBeforeMeridiem then " " else ""

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
        @start.from(@end.clone().add(1, "day"), true)
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
  overlaps: (other) -> (@_trueEnd().isAfter(other._trueStart()) && @_trueStart().isBefore(other._trueEnd()))

  engulfs: (other) -> @_trueStart() <= other._trueStart() && @_trueEnd() >= other._trueEnd()

  union: (other) ->
    allDay = @allDay && other.allDay
    if allDay
      newStart = if @start < other.start then @start else other.start
      newEnd = if @end > other.end then @end else other.end
    else
      newStart = if @_trueStart() < other._trueStart() then @_trueStart() else other._trueStart()
      newEnd = if @_trueEnd() > other._trueEnd() then @_trueEnd() else other._trueEnd()

    new Twix(newStart, newEnd, allDay)

  intersection: (other) ->
    newStart = if @start > other.start then @start else other.start
    if @allDay
      end = moment @end # Clone @end
      end.add(1, "day")
      end.subtract(1, "millisecond")
      if other.allDay
        newEnd = if end < other.end then @end else other.end
      else
        newEnd = if end < other.end then end else other.end
    else
      newEnd = if @end < other.end then @end else other.end

    allDay = @allDay && other.allDay
    new Twix(newStart, newEnd, allDay)

  isValid: ->
    @_trueStart() <= @_trueEnd()

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
      twentyFourHour: @langData._twix.twentyFourHour
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
      @end.clone().startOf("day").valueOf() == @start.clone().add(1, "day").startOf("day").valueOf() &&
      @start.hours() > 12 &&
      @end.hours() < options.lastNightEndsAt

    needDate = options.showDate || (!@isSame("day") && !goesIntoTheMorning)

    if @allDay && @isSame("day") && (!options.showDate || options.explicitAllDay)
      fs.push
        name: "all day simple"
        fn: @_twix_fn('allDaySimple', options)
        pre: @_twix_pre('allDaySimple', options)
        slot: @_twix_slot('allDaySimple')

    if needDate && (!options.implicitYear || @start.year() != moment().year() || !@isSame("year"))
      fs.push
        name: "year",
        fn: @_twix_fn('year', options)
        pre: @_twix_pre('year', options)
        slot: @_twix_slot('year')

    if !@allDay && needDate
      fs.push
        name: "all day month"
        fn: @_twix_fn('allDayMonth', options)
        ignoreEnd: -> goesIntoTheMorning
        pre: @_twix_pre('allDayMonth', options)
        slot: @_twix_slot('allDayMonth')

    if @allDay && needDate
      fs.push
        name: "month"
        fn: @_twix_fn('month', options)
        pre: @_twix_pre('month', options)
        slot: @_twix_slot('month')

    if @allDay && needDate
      fs.push
        name: "date"
        fn: @_twix_fn('date', options)
        pre: @_twix_pre('date', options)
        slot: @_twix_slot('date')

    if needDate && options.showDayOfWeek
      fs.push
        name: "day of week",
        fn: @_twix_fn('dayOfWeek', options)
        pre: @_twix_pre('dayOfWeek', options)
        slot: @_twix_slot('dayOfWeek')

    if options.groupMeridiems && !options.twentyFourHour && !@allDay
      fs.push
        name: "meridiem",
        fn: @_twix_fn('meridiem', options)
        pre: @_twix_pre('meridiem', options)
        slot: @_twix_slot('meridiem')

    if !@allDay
      fs.push
        name: "time",
        fn: @_twix_fn('time', options)
        pre: @_twix_pre('time', options)
        slot: @_twix_slot('time')

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

  # -- INTERNAL
  _trueStart: -> if @allDay then @start.clone().startOf("day") else @start
  _trueEnd: -> if @allDay then @end.clone().endOf("day") else @end

  _iterateHelper: (period, iter, hasNext) ->
    next: =>
      unless hasNext()
        null
      else
        val = iter.clone()
        iter.add(1, period)
        val
    hasNext: hasNext

  _inner: (period) ->
    start = @start.clone().startOf(period)
    end = @end.clone().startOf(period)
    (if @allDay then end else start).add(period, 1)
    [start, end]

  _twix_fn: (name, options) ->
    @langData._twix[name].fn(options)

  _twix_slot: (name) ->
    @langData._twix[name].slot

  _twix_pre: (name, options) ->
    if typeof @langData._twix[name].pre == "function"
      @langData._twix[name].pre(options)
    else
      @langData._twix[name].pre

  _deprecate: (name, instead, fn) ->
    console.warn "##{name} is deprecated. Use ##{instead} instead." if console && console.warn
    fn.apply @

  # -- DEPRECATED METHODS --
  sameDay: -> @_deprecate "sameDay", "isSame('day')", -> @isSame "day"
  sameYear: -> @_deprecate "sameYear", "isSame('year')", -> @isSame "year"
  countDays: -> @_deprecate "countDays", "countOuter('days')", -> @countOuter "days"
  daysIn: (minHours) -> @_deprecate "daysIn", "iterate('days' [,minHours])", -> @iterate 'days', minHours
  past: -> @_deprecate "past", "isPast()", -> @isPast()
  duration: -> @_deprecate "duration", "humanizeLength()", -> @humanizeLength()
  merge: (other) -> @_deprecate "merge", "union(other)", -> @union other

extend = (first, second) ->
  for attr of second
    first[attr] = second[attr] unless typeof second[attr] == "undefined"

extend(Object.getPrototypeOf(moment.fn._lang),
  _twix: Twix.defaults
)

if typeof module != "undefined"
  module.exports = Twix
else
  window.Twix = Twix

moment.twix = -> new Twix(arguments...)
moment.fn.twix = -> new Twix(this, arguments...)
moment.fn.forDuration = (duration, allDay) -> new Twix(this, this.clone().add(duration), allDay)
moment.duration.fn.afterMoment = (startingTime, allDay) -> new Twix(startingTime, moment(startingTime).clone().add(this), allDay)
moment.duration.fn.beforeMoment = (startingTime, allDay) -> new Twix(moment(startingTime).clone().subtract(this), startingTime, allDay)
