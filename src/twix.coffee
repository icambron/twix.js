hasModule = module? && module.exports? && typeof(require) == 'function'

isArray = (input) ->
  Object.prototype.toString.call(input) == '[object Array]'

makeTwix = (moment) ->
  throw new Error("Can't find moment") unless moment?

  class Twix
    constructor: (start, end, parseFormat, options = {}) ->

      unless typeof parseFormat == 'string'
        options = parseFormat ? {}
        parseFormat = null

      options = {allDay: options} if typeof options == 'boolean'

      @_oStart = moment start, parseFormat, options.parseStrict
      @_oEnd = moment end, parseFormat, options.parseStrict

      @allDay = options.allDay ? false

      @_mutated()

    @_extend: (first, others...) ->
      for other in others
        for attr of other
          first[attr] = other[attr] unless typeof other[attr] == 'undefined'
      first

    # -- INFORMATIONAL --
    start: -> @_start.clone()
    end: -> @_end.clone()

    isSame: (period) -> @_start.isSame @_end, period

    length: (period, floatingPoint = false) ->
      @_displayEnd.diff @_start, period, floatingPoint

    count: (period) ->
      start = @start().startOf period
      end = @end().startOf period
      end.diff(start, period) + 1

    countInner: (period) ->
      [start, end] = @_inner period

      return 0 if start >= end
      end.diff(start, period)

    iterate: (intervalAmount, period, minHours) ->
      [intervalAmount, period, minHours] = @_prepIterateInputs intervalAmount, period, minHours

      start = @start().startOf period
      end = @end().startOf period
      end = end.add(1, 'd') if @allDay
      hasNext = => (!@allDay && start <= end && (!minHours || !start.isSame(end) || @_end.hours() > minHours)) || (@allDay && start < end)

      @_iterateHelper period, start, hasNext, intervalAmount

    iterateInner: (intervalAmount, period) ->
      [intervalAmount, period] = @_prepIterateInputs intervalAmount, period

      [start, end] = @_inner period, intervalAmount
      hasNext = -> start < end

      @_iterateHelper period, start, hasNext, intervalAmount

    humanizeLength: ->
      if @allDay
        if @isSame 'd'
          'all day'
        else
          @_start.from(@end().add(1, 'd'), true)
      else
        @_start.from(@_end, true)

    asDuration: (units) ->
      diff = @_end.diff @_start
      moment.duration(diff)

    isPast: ->
      @_lastMilli < moment()

    isFuture: ->
      @_start > moment()

    isCurrent: -> !@isPast() && !@isFuture()

    contains: (mom) ->
      mom = moment mom unless moment.isMoment(mom)
      @_start <= mom && @_lastMilli >= mom

    isEmpty: ->
      @_start.isSame(@_displayEnd)

    # -- WORK WITH MULTIPLE RANGES --
    overlaps: (other) -> (@_displayEnd.isAfter(other._start) && @_start.isBefore(other._displayEnd))

    engulfs: (other) -> @_start <= other._start && @_displayEnd >= other._displayEnd

    union: (other) ->
      allDay = @allDay && other.allDay
      newStart = if @_start < other._start then @_start else other._start
      newEnd = if @_lastMilli > other._lastMilli
        (if allDay then @_end else @_displayEnd)
      else
        (if allDay then other._end else other._displayEnd)
      new Twix(newStart, newEnd, allDay)

    intersection: (other) ->
      allDay = @allDay && other.allDay
      newStart = if @_start > other._start then @_start else other._start
      newEnd = if @_lastMilli < other._lastMilli
        (if allDay then @_end else @_displayEnd)
      else
        (if allDay then other._end else other._displayEnd)

      new Twix(newStart, newEnd, allDay)

    xor: (others...) ->
      open = 0
      start = null
      results = []

      allDay = (o for o in others when o.allDay).length == others.length

      arr = []
      for item, i in [this].concat(others)
        arr.push({time: item._start, i: i, type: 0})
        arr.push({time: item._displayEnd, i: i, type: 1})
      arr = arr.sort((a, b) -> a.time - b.time)

      for other in arr
        open -= 1 if other.type == 1
        if open == other.type
          start = other.time
        if open == (other.type + 1) % 2
          if start
            last = results[results.length - 1]
            if last && last._end.isSame(start)
              last._oEnd = other.time
              last._mutated()
            else
              #because we used the diffable end, we have to subtract back off a day. blech
              endTime = if allDay then other.time.clone().subtract(1, 'd') else other.time
              t = new Twix(start, endTime, allDay)
              results.push(t) if !t.isEmpty()
          start = null
        open += 1 if other.type == 0
      results

    difference: (others...) ->
      t for t in @xor(others...).map((i) => @intersection(i)) when !t.isEmpty() && t.isValid()

    split: (args...) ->
      end = start = @start()

      if moment.isDuration(args[0])
        dur = args[0]
      else if (!moment.isMoment(args[0]) && !isArray(args[0]) && typeof args[0] == 'object') || (typeof args[0] == 'number' && typeof args[1] == 'string')
        dur = moment.duration args[0], args[1]
      else if isArray(args[0])
        times = args[0]
      else
        times = args

      if times
        times = (moment(time) for time in times)
        times = (mom for mom in times when mom.isValid() && mom >= start).sort((a, b) -> a.valueOf() - b.valueOf())

      return [this] if (dur && dur.asMilliseconds() == 0) || (times && times.length == 0)

      vals = []; i = 0; final = @_displayEnd
      while start < final && (!times? || times[i])
        end = if dur then start.clone().add(dur) else times[i].clone()
        end = moment.min(final, end)
        vals.push(moment.twix(start, end)) if !start.isSame(end)
        start = end
        i += 1
      if !end.isSame(@_displayEnd) && times
        vals.push(moment.twix(end, @_displayEnd))
      vals

    divide: (parts) ->
      @split(@length() / parts, 'ms')[0..(parts - 1)]

    isValid: ->
      @_start.isValid() && @_end.isValid() && @_start <= @_displayEnd

    equals: (other) ->
      (other instanceof Twix) &&
        @allDay == other.allDay &&
        @_start.valueOf() == other._start.valueOf() &&
        @_end.valueOf() == other._end.valueOf()

    # -- FORMATING --
    toString: -> "{start: #{@_start.format()}, end: #{@_end.format()}, allDay: #{if @allDay then 'true' else 'false'}}"

    toArray: (intervalAmount, period, minHours) ->
      itr = @iterate(intervalAmount, period, minHours)
      range = []
      while itr.hasNext()
        range.push itr.next()
      range

    simpleFormat: (momentOpts, inopts) ->
      options =
        allDay: '(all day)'
        template: Twix.formatTemplate

      Twix._extend options, (inopts || {})

      s = options.template @_start.format(momentOpts), @_end.format(momentOpts)
      s += " #{options.allDay}" if @allDay && options.allDay
      s

    format: (inopts) ->

      return '' if @isEmpty()

      momentHourFormat = @_start.localeData()._longDateFormat['LT'][0]

      options =
        groupMeridiems: true
        spaceBeforeMeridiem: true
        spaceBeforeMonth: true
        spaceBeforeDay: true
        showDayOfWeek: false
        showYearFirst: false
        hideTime: false
        hideYear: false
        implicitMinutes: true
        implicitDate: false
        implicitYear: true
        yearFormat: 'YYYY'
        monthFormat: 'MMM'
        weekdayFormat: 'ddd'
        dayFormat: 'D'
        meridiemFormat: 'A'
        hourFormat: momentHourFormat
        minuteFormat: 'mm'
        allDay: 'all day'
        explicitAllDay: false
        lastNightEndsAt: 0
        template: Twix.formatTemplate

      Twix._extend options, (inopts || {})

      fs = []

      needsMeridiem = options.hourFormat && options.hourFormat[0] == 'h'

      localFormat = @_start.localeData()._longDateFormat['L']
      americanish = localFormat.indexOf('M') < localFormat.indexOf('D')

      goesIntoTheMorning =
        options.lastNightEndsAt > 0 &&
        !@allDay &&
        @end().startOf('d').valueOf() == @start().add(1, 'd').startOf('d').valueOf() &&
        @_start.hours() > 12 &&
        @_end.hours() < options.lastNightEndsAt

      needDate = !options.hideDate &&
        (!options.implicitDate || @start().startOf('d').valueOf() != moment().startOf('d').valueOf() || !(@isSame('d') || goesIntoTheMorning))

        atomicMonthDate = !(@allDay || options.hideTime)

      if @allDay && @isSame('d') && (options.implicitDate || options.explicitAllDay)
        fs.push
          name: 'all day simple'
          fn: () -> options.allDay
          pre: ' '
          slot: 0

      if needDate && !options.hideYear && (!options.implicitYear || @_start.year() != moment().year() || !@isSame('y'))
        fs.push
          name: 'year',
          fn: (date) -> date.format options.yearFormat
          pre: if americanish then ', ' else ' '
          slot: if options.showYearFirst then -1 else 4

      if atomicMonthDate && needDate
        fs.push
          name: 'month-date'
          fn: (date) ->
            format =
              if americanish
                "#{options.monthFormat} #{options.dayFormat}"
              else
                "#{options.dayFormat} #{options.monthFormat}"
            date.format format
          ignoreEnd: -> goesIntoTheMorning
          pre: ' '
          slot: 2

      if !atomicMonthDate && needDate
        fs.push
          name: 'month'
          fn: (date) -> date.format options.monthFormat
          pre: if options.spaceBeforeMonth then ' ' else ''
          slot: if americanish then 2 else 3

      if !atomicMonthDate && needDate
        fs.push
          name: 'date'
          fn: (date) -> date.format options.dayFormat
          pre: if options.spaceBeforeDay then ' ' else ''
          slot: if americanish then 3 else 2

      if needDate && options.showDayOfWeek
        fs.push
          name: 'day of week',
          fn: (date) -> date.format options.weekdayFormat
          pre: ' '
          slot: 1

      if options.groupMeridiems && needsMeridiem && !@allDay && !options.hideTime
        fs.push
          name: 'meridiem',
          fn: (t) -> t.format options.meridiemFormat
          slot: 6
          pre: if options.spaceBeforeMeridiem then ' ' else ''

      if !@allDay && !options.hideTime
        fs.push

          name: 'time',
          fn: (date) ->
            str =
              if date.minutes() == 0 && options.implicitMinutes && needsMeridiem
                date.format options.hourFormat
              else
                date.format "#{options.hourFormat}:#{options.minuteFormat}"

            if !options.groupMeridiems && needsMeridiem
              str += ' ' if options.spaceBeforeMeridiem
              str += date.format options.meridiemFormat
            str
          slot: 5
          pre: ', '

      start_bucket = []
      end_bucket = []
      common_bucket = []
      together = true

      process = (format) =>
        start_str = format.fn @_start

        end_str =
          if format.ignoreEnd && format.ignoreEnd()
            start_str
          else format.fn @_end

        start_group = {format: format, value: -> start_str}

        if end_str == start_str && together
          common_bucket.push start_group
        else
          if together
            together = false
            common_bucket.push {
              format: {slot: format.slot, pre: ''}
              value: -> options.template(fold(start_bucket), fold(end_bucket, true).trim())
            }

          start_bucket.push start_group
          end_bucket.push {format: format, value: -> end_str}

      process format for format in fs

      global_first = true
      fold = (array, skip_pre) ->
        local_first = true
        str = ''
        for section in array.sort((a, b) -> a.format.slot - b.format.slot)

          unless global_first
            if local_first && skip_pre
              str += ' '
            else
              str += section.format.pre

          str += section.value()

          global_first = false
          local_first = false
        str

      fold common_bucket

    # -- INTERNAL --
    _iterateHelper: (period, iter, hasNext, intervalAmount) ->
      next: ->
        unless hasNext()
          null
        else
          val = iter.clone()
          iter.add(intervalAmount, period)
          val
      hasNext: hasNext

    _prepIterateInputs: (inputs...) ->
      return inputs if typeof inputs[0] is 'number'

      if typeof inputs[0] == 'string'
        period = inputs.shift()
        intervalAmount = inputs.pop() ? 1

        if inputs.length
          minHours = inputs[0] ? false

      if moment.isDuration inputs[0]
        period = 'ms'
        intervalAmount = inputs[0].as period

      [intervalAmount, period, minHours]

    _inner: (period = 'ms', intervalAmount = 1) ->
      start = @start()
      end = @_displayEnd.clone()

      start.startOf(period).add(intervalAmount, period) if start > start.clone().startOf(period)
      end.startOf(period) if end < end.clone().endOf(period)

      durationPeriod = start.twix(end).asDuration period
      durationCount = durationPeriod.get(period)

      modulus = durationCount % intervalAmount

      end.subtract(modulus, period)

      [start, end]

    _mutated: ->
      @_start = if @allDay then @_oStart.clone().startOf('d') else @_oStart
      @_lastMilli = if @allDay then @_oEnd.clone().endOf('d') else @_oEnd
      @_end = if @allDay then @_oEnd.clone().startOf('d') else @_oEnd
      @_displayEnd = if @allDay then @_end.clone().add(1, 'd') else @_end

  # -- PLUGIN --
  Twix._extend(moment.locale(), _twix: Twix.defaults)

  Twix.formatTemplate = (leftSide, rightSide) -> "#{leftSide} - #{rightSide}"

  moment.twix = -> new Twix(arguments...)
  moment.fn.twix = -> new Twix(this, arguments...)
  moment.fn.forDuration = (duration, allDay) -> new Twix(this, this.clone().add(duration), allDay)
  if moment.duration.fn
    moment.duration.fn.afterMoment = (startingTime, allDay) -> new Twix(startingTime, moment(startingTime).clone().add(this), allDay)
    moment.duration.fn.beforeMoment = (startingTime, allDay) -> new Twix(moment(startingTime).clone().subtract(this), startingTime, allDay)
  moment.twixClass = Twix

  Twix

# -- MAKE AVAILABLE
return module.exports = makeTwix(require 'moment') if hasModule

if typeof(define) == 'function' && define.amd
  define 'twix', ['moment'], (moment) -> makeTwix(moment)


if @moment
  @Twix = makeTwix(@moment)
else if moment?
  # Also checks globals (Meteor)
  @Twix = makeTwix(moment)
