hasModule = module? && module.exports?

deprecate = (name, instead, fn) ->
  alreadyDone = false
  (args...) ->
    unless alreadyDone
      console?.warn? "##{name} is deprecated. Use ##{instead} instead."
    alreadyDone = true
    fn.apply @, args

isArray = (input) ->
  Object.prototype.toString.call(input) == '[object Array]'

makeTwix = (moment) ->
  throw "Can't find moment" unless moment?

  locales = {}

  loadLocale = (mom) ->
    loc = mom.locale()
    return locales[loc] if locales[loc]?

    settings = mom.localeData()._longDateFormat
    dateFormat = settings.LLLL.replace('LT', settings.LT)

    locData = parseFormat(dateFormat)
    locales[loc] = locData
    locData

  parseFormat = (format, options = {}) ->

    #what i would give to be able to use [].reduce
    results = {}

    for elem, i in format.match(/(\W+)?[a-zA-Z]+/g)
      matches = elem.match(/(\W*)(\w+)/)
      if matches?
        [_, pre, format] = matches
        unitMaybe = moment.normalizeUnits(moment.normalizeUnits(format[0]))
        unit = if unitMaybe == 'a' then 'meridiem' else unitMaybe
        override = options[unit + "Format"]

        results[unit] =
          slot: i + 1
          format: override || format
          pre: pre

    results

  class Twix
    constructor: (start, end, parseFormat, options = {}) ->

      unless typeof parseFormat == "string"
        options = parseFormat ? {}
        parseFormat = null

      options = {allDay: options} if typeof options == "boolean"

      @start = moment start, parseFormat, options.parseStrict
      @end = moment end, parseFormat, options.parseStrict
      @allDay = options.allDay ? false

      @_trueStart = if @allDay then @start.clone().startOf("day") else @start
      @_trueEnd = if @allDay then @end.startOf('d').clone().add(1, "day") else @end

    @_extend: (first, others...) ->
      for other in others
        for attr of other
          first[attr] = other[attr] unless typeof other[attr] == "undefined"
      first

    @registerLang: (name, options) ->
      moment.locale name, twix: Twix._extend {}, Twix.defaults, options

    # -- INFORMATIONAL --
    isSame: (period) -> @start.isSame @end, period

    length: (period) ->
      @_trueEnd.diff @_trueStart, period

    count: (period) ->
      start = @start.clone().startOf period
      end = @end.clone().startOf period
      end.diff(start, period) + 1

    countInner: (period) ->
      [start, end] = @_inner period

      return 0 if start >= end
      end.diff(start, period)

    iterate: (intervalAmount = 1, period, minHours) ->
      [intervalAmount, period, minHours] = @_prepIterateInputs intervalAmount, period, minHours

      start = @_trueStart.clone().startOf period
      end = @_trueEnd.clone().startOf period
      hasNext = => (!@allDay && start <= end && (!minHours || !start.isSame(end) || @end.hours() > minHours)) || (@allDay && start < end)

      @_iterateHelper period, start, hasNext, intervalAmount

    iterateInner: (intervalAmount = 1, period) ->
      [intervalAmount, period] = @_prepIterateInputs intervalAmount, period

      [start, end] = @_inner period, intervalAmount
      hasNext = -> start < end

      @_iterateHelper period, start, hasNext, intervalAmount

    humanizeLength: (options = {}) ->
      if @allDay
        if @isSame "day"
          options.allDay || "all day"
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
      mom = moment mom unless moment.isMoment(mom)
      @_trueStart <= mom && @_trueEnd >= mom

    isEmpty: ->
      @_trueStart.isSame(@_trueEnd)

    # -- WORK WITH MULTIPLE RANGES --
    overlaps: (other) -> (@_trueEnd.isAfter(other._trueStart) && @_trueStart.isBefore(other._trueEnd))

    engulfs: (other) -> @_trueStart <= other._trueStart && @_trueEnd >= other._trueEnd

    union: (other) ->
      allDay = @allDay && other.allDay
      if allDay
        newStart = if @start < other.start then @start else other.start
        newEnd = if @end > other.end then @end else other.end
      else
        newStart = if @_trueStart < other._trueStart then @_trueStart else other._trueStart
        newEnd = if @_trueEnd > other._trueEnd then @_trueEnd else other._trueEnd

      new Twix(newStart, newEnd, allDay)

    intersection: (other) ->
      allDay = @allDay && other.allDay
      if allDay
        newStart = if @start > other.start then @start else other.start
        newEnd = if @end < other.end then @end else other.end
      else
        newStart = if @_trueStart > other._trueStart then @_trueStart else other._trueStart
        newEnd = if @_trueEnd < other._trueEnd then @_trueEnd else other._trueEnd

      new Twix(newStart, newEnd, allDay)

    xor: (others...) ->
      open = 0
      start = null
      results = []

      allDay = (o for o in others when o.allDay).length == others.length

      arr = []
      for item, i in [@].concat(others)
        arr.push({time: item._trueStart, i: i, type: 0})
        arr.push({time: item._trueEnd, i: i, type: 1})
      arr = arr.sort((a, b) -> a.time - b.time)

      for other in arr
        open -= 1 if other.type == 1
        if open == other.type
          start = other.time
        if open == (other.type + 1) % 2
          if start
            last = results[results.length - 1]
            if last && last.end.isSame(start)
              last.end = other.time
            else
              #because we used the diffable end, we have to subtract back off a day. blech
              endTime = if allDay then other.time.subtract(1, 'd') else other.time
              t = new Twix(start, endTime, allDay)
              results.push(t) if !t.isEmpty()
          start = null
        open += 1 if other.type == 0
      results

    difference: (others...) ->
      t for t in @xor(others...).map((i) => @intersection(i)) when !t.isEmpty() && t.isValid()

    split: (args...) ->
      end = start = @_trueStart.clone()

      if moment.isDuration(args[0])
        dur = args[0]
      else if (!moment.isMoment(args[0]) && !isArray(args[0]) && typeof args[0] == "object") ||
       (typeof args[0] == "number" && typeof args[1] == "string")
        dur = moment.duration args[0], args[1]
      else if isArray(args[0])
        times = args[0]
      else
        times = args

      if times
        times = (moment(time) for time in times)
        times = (mom for mom in times when mom.isValid() && mom >= start).sort()

      return [@] if (dur && dur.asMilliseconds() == 0) || (times && times.length == 0)

      vals = []; i = 0; final = @_trueEnd
      while start < final && (!times? || times[i])
        end = if dur then start.clone().add(dur) else times[i].clone()
        end = moment.min(final, end)
        vals.push(moment.twix(start, end)) if !start.isSame(end)
        start = end
        i += 1
      if !end.isSame(@_trueEnd) && times
        vals.push(moment.twix(end, @_trueEnd))
      vals

    isValid: -> @_trueStart <= @_trueEnd

    equals: (other) ->
      (other instanceof Twix) &&
        @allDay == other.allDay &&
        @start.valueOf() == other.start.valueOf() &&
        @end.valueOf() == other.end.valueOf()

    # -- FORMATING --
    toString: -> "{start: #{@start.format()}, end: #{@end.format()}, allDay: #{@allDay ? "true" : "false"}}"

    simpleFormat: (momentOpts, inopts) ->
      options =
        allDay: "(all day)"
        template: Twix.formatTemplate

      Twix._extend options, (inopts || {})

      s = options.template @start.format(momentOpts), @end.format(momentOpts)
      s += " #{options.allDay}" if @allDay && options.allDay
      s

    format: (inopts) ->

      return "" if @isEmpty()

      options =
        groupMeridiems: true
        spaceBeforeMeridiem: true
        showDate: true
        showDayOfWeek: false
        implicitMinutes: true
        implicitYear: true
        allDay: "all day"
        explicitAllDay: false
        lastNightEndsAt: 0
        template: Twix.formatTemplate

      Twix._extend options, (inopts || {})

      tokens = if options.parseFormat? then parseFormat(options.parseFormat) else loadLocale(@start, options)

      #options.hourFormat = options.hourFormat.replace("h", "H") if options.twentyFourHour

      fs = []

      goesIntoTheMorning =
        options.lastNightEndsAt > 0 &&
        !@allDay &&
        @end.clone().startOf("d").valueOf() == @start.clone().add(1, "d").startOf("d").valueOf() &&
        @start.hours() > 12 &&
        @end.hours() < options.lastNightEndsAt

      needDate = options.showDate || (!@isSame("d") && !goesIntoTheMorning)

      simple = (name, overrides = {}) ->
        item = tokens[name]
        name: name
        fn: overrides.fn || (date) -> date.format(item.format)
        slot: overrides.slot || item.slot
        pre: item.pre

      if @allDay && @isSame("d") && (!options.showDate || options.explicitAllDay)
        fs.push
          name: "all day simple"
          fn: -> options.allDay
          slot: 0

      if needDate && (!options.implicitYear || @start.year() != moment().year() || !@isSame("y"))
        fs.push(simple "year")

      #make the month and date show up together even if the month is common
      #todo - is this a good way to do this? are there languages where this isn't valid?
      if !@allDay && needDate
        fs.push
          name: "bundled month/date"
          fn: (date) ->
            sorted = [tokens["month"], tokens["date"]].sort((a, b) -> a.format.slot - b.format.slot)
            "#{date.format(sorted[0].format)} #{date.format(sorted[1].format)}"
          pre: tokens["month"].pre
          ignoreEnd: -> goesIntoTheMorning
          slot: tokens["month"].slot

      if @allDay && needDate
        fs.push(simple "month")
        fs.push(simple "date")

      if needDate && options.showDayOfWeek
        fs.push(simple "day")

      if options.groupMeridiems && !options.twentyFourHour && !@allDay
        fs.push(simple "meridiem")

      if !@allDay
        fs.push(simple "hour")
        fs.push(simple "minute", fn:
          (date) ->
            if date.minutes() == 0 && options.implicitMinutes && !options.twentyFourHour
                null
            else
              date.format tokens["minute"].format
        )

      startBucket = []
      endBucket = []
      commonBucket = []
      together = true

      for format in fs
        do =>
          startStr = format.fn @start
          endStr = if format.ignoreEnd?() then startStr else format.fn @end
          startGroup = {format: format, value: -> startStr}

          if endStr == startStr && together
            commonBucket.push startGroup
          else
            if together
              together = false
              commonBucket.push {
                format: {slot: format.slot, pre: ""}
                value: -> options.template(fold(startBucket), fold(endBucket, true).trim())
              }

            startBucket.push startGroup
            endBucket.push {format: format, value: -> endStr}

      globalFirst = true
      fold = (array, skipPre) =>
        localFirst = true
        str = ""

        for section in array.sort((a, b) -> a.format.slot - b.format.slot)

          val = section.value()

          if val != null

            unless globalFirst
              if localFirst && skipPre
                str += " "
              else
                str += section.format.pre

            str += val

            globalFirst = false
            localFirst = false
        str

      fold commonBucket

    # -- INTERNAL
    _iterateHelper: (period, iter, hasNext, intervalAmount = 1) ->
      next: =>
        unless hasNext()
          null
        else
          val = iter.clone()
          iter.add(intervalAmount, period)
          val
      hasNext: hasNext

    _prepIterateInputs: (inputs...)->
      return inputs if typeof inputs[0] is "number"

      if typeof inputs[0] == "string"
        period = inputs.shift()
        intervalAmount = inputs.pop() ? 1

        if inputs.length
          minHours = inputs[0] ? false

      if moment.isDuration inputs[0]
        period = 'ms'
        intervalAmount = inputs[0].as period

      [intervalAmount, period, minHours]

    _inner: (period = "ms", intervalAmount = 1) ->
      start = @_trueStart.clone()
      end = @_trueEnd.clone()

      start.startOf(period).add(intervalAmount, period) if start > start.clone().startOf(period)
      end.startOf(period) if end < end.clone().endOf(period)

      durationPeriod = start.twix(end).asDuration period
      durationCount = durationPeriod.get(period)

      modulus = durationCount % intervalAmount

      end.subtract(modulus, period)

      [start, end]

    # -- DEPRECATED METHODS --
    sameDay: deprecate "sameDay", "isSame('day')", -> @isSame "day"
    sameYear: deprecate "sameYear", "isSame('year')", -> @isSame "year"
    countDays: deprecate "countDays", "countOuter('days')", -> @countOuter "days"
    daysIn: deprecate "daysIn", "iterate('days' [,minHours])", (minHours) -> @iterate 'days', minHours
    past: deprecate "past", "isPast()", -> @isPast()
    duration: deprecate "duration", "humanizeLength()", -> @humanizeLength()
    merge: deprecate "merge", "union(other)", (other) -> @union other

  # -- PLUGIN --

  Twix._extend(moment._locale, _twix: Twix.defaults)

  Twix.formatTemplate = (leftSide, rightSide) -> "#{leftSide} - #{rightSide}"

  moment.twix = -> new Twix(arguments...)
  moment.fn.twix = -> new Twix(this, arguments...)
  moment.fn.forDuration = (duration, allDay) -> new Twix(this, this.clone().add(duration), allDay)
  moment.duration.fn.afterMoment = (startingTime, allDay) -> new Twix(startingTime, moment(startingTime).clone().add(this), allDay)
  moment.duration.fn.beforeMoment = (startingTime, allDay) -> new Twix(moment(startingTime).clone().subtract(this), startingTime, allDay)
  moment.twixClass = Twix

  Twix

# -- MAKE AVAILABLE
module.exports = makeTwix(require "moment") if hasModule

if  typeof(define) == "function"
  define "twix", ["moment"], (moment) -> makeTwix(moment)

@Twix = makeTwix(@moment) if @moment?
