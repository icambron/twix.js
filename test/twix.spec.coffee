if typeof module != "undefined"
  moment = require "moment"
  Twix = require "../../bin/twix"
else
  moment = window.moment
  Twix = window.Twix

assertEqual = (a, b) -> throw new Error("Found #{b}, expected #{a}") unless a == b
assertTwixEqual = (a, b) -> throw new Error("Found #{b.toString()}, expected #{a.toString()}") unless a.equals b

thisYear = (partial, time) ->
  fullDate = "#{partial}/#{moment().year()}"
  fullDate += " #{time}" if time
  moment fullDate

nextYear = (partial, time) -> thisYear(partial, time).add("years", 1)

yesterday = -> moment().subtract('days', 1).startOf 'day'
tomorrow = -> moment().add('days', 1).startOf 'day'

thatDay = (start, end) ->
  if start
    moment("5/25/1982 #{start}").twix "5/25/1982 #{end}"
  else
    moment("5/25/1982").twix "5/25/1982", true

describe "plugin", ->
  describe "static constructor", ->
    it "is the same as instantiating via the contructor", ->
      assertEqual "function", typeof moment.twix
      assertTwixEqual new Twix("5/25/1982", "5/25/1983", true), moment.twix("5/25/1982", "5/25/1983", true)

  describe "create from a member", ->
    it "is the same as instantiating via the contructor", ->
      assertEqual "function", typeof(moment().twix)
      assertTwixEqual new Twix("5/25/1982", "5/25/1983", true), moment("5/25/1982").twix("5/25/1983", true)

  describe "moment.forDuration()", ->
    it "constructs a twix", ->
      from = thisYear("5/25")
      to = thisYear("5/26")
      duration = moment.duration(to.diff from)
      twix = from.forDuration duration
      assertTwixEqual new Twix(from, to), twix

    it "constructs an all-day twix", ->
      from = thisYear("5/25")
      to = thisYear("5/26")
      duration = moment.duration(to.diff from)
      twix = from.forDuration duration, true
      assertTwixEqual new Twix(from, to, true), twix

  describe "duration.afterMoment()", ->
    it "contructs a twix", ->
      d = moment.duration(2, "days")
      twix = d.afterMoment thisYear("5/25")
      assertTwixEqual new Twix(thisYear("5/25"), thisYear("5/27")), twix

    it "can use text", ->
      d = moment.duration(2, "days")
      twix = d.afterMoment "5/25/1982"
      assertTwixEqual new Twix("5/25/1982", "5/27/1982"), twix

    it "contructs an all-day twix", ->
      d = moment.duration(2, "days")
      twix = d.afterMoment thisYear("5/25"), true
      assertTwixEqual new Twix(thisYear("5/25"), thisYear("5/27"), true), twix

  describe "duration.beforeMoment()", ->
    it "contructs a twix", ->
      d = moment.duration(2, "days")
      twix = d.beforeMoment thisYear("5/25")
      assertTwixEqual new Twix(thisYear("5/23"), thisYear("5/25")), twix

    it "can use text", ->
      d = moment.duration(2, "days")
      twix = d.beforeMoment "5/25/1982"
      assertTwixEqual new Twix("5/23/1982", "5/25/1982"), twix

    it "contructs an all-day twix", ->
      d = moment.duration(2, "days")
      twix = d.beforeMoment thisYear("5/25"), true
      assertTwixEqual new Twix(thisYear("5/23"), thisYear("5/25"), true), twix

describe "isSame()", ->

  describe "year", ->
    it "returns true if they're the same year", ->
      assertEqual true, moment("5/25/1982").twix("10/14/1982").isSame "year"

    it "returns false if they're different years", ->
      assertEqual false, moment("5/25/1982").twix("10/14/1983").isSame "year"

  describe "day", ->

    it "returns true if they're the same day", ->
      assertEqual true, moment("5/25/1982 5:30 AM").twix("5/25/1982 7:30 PM").isSame "day"

    it "returns false if they're different days day", ->
      assertEqual false, moment("5/25/1982 5:30 AM").twix("5/26/1982 7:30 PM").isSame "day"

    it "returns true they're in different UTC days but the same local days", ->
      assertEqual true, moment("5/25/1982 5:30 AM").twix("5/25/1982 11:30 PM").isSame "day"

describe "length()", ->
  describe "days", ->
    it "returns 1 for yesterday - today", ->
      assertEqual 1, yesterday().twix(moment()).length("days")

    it "returns 1 for a one-day all-day event", ->
      assertEqual 1, moment().twix(moment(), true).length("days")

    it "returns 2 for a two-day all-day event", ->
      assertEqual 2, yesterday().twix(moment(), true).length("days")

  describe "other", ->
    it "returns the right number for a years", ->
      assertEqual 16, moment("1996-2-17").twix("2012-8-14").length("years")

    it "returns the right number for a months", ->
      assertEqual 197, moment("1996-2-17").twix("2012-8-14").length("months")

describe "count()", ->

  describe "days", ->

    it "returns 1 inside a day", ->
      start = thisYear "5/25", "3:00"
      end = thisYear "5/25", "14:00"
      range = moment(start).twix end
      assertEqual 1, range.count("days")

    it "returns 2 if the range crosses midnight", ->
      start = thisYear "5/25", "16:00"
      end = thisYear "5/26", "3:00"
      range = moment(start).twix end
      assertEqual 2, range.count("days")

    it "works fine for all-day events", ->
      start = thisYear "5/25"
      end = thisYear "5/26"
      range = moment(start).twix end, true
      assertEqual 2, range.count("days")

  describe "years", ->

    it "returns 1 inside a year", ->
      start = thisYear "5/25"
      end = thisYear "5/26"
      assertEqual 1, moment(start).twix(end).count("year")

    it "returns 2 if the range crosses Jan 1", ->
      start = thisYear "5/25"
      end = nextYear "5/26"
      assertEqual 2, moment(start).twix(end).count("year")

describe "countInner()", ->
  describe "days", ->

    it "returns 0 inside a day", ->
      start = thisYear "5/25", "3:00"
      end = thisYear "5/25", "14:00"
      range = moment(start).twix end
      assertEqual 0, range.countInner("days")

    it "returns 0 if the range crosses midnight but is still < 24 hours", ->
      start = thisYear "5/25", "16:00"
      end = thisYear "5/26", "3:00"
      range = moment(start).twix end
      assertEqual 0, range.countInner("days")

    it "returns 0 if the range is > 24 hours but still doesn't cover a full day", ->
      start = thisYear "5/25", "16:00"
      end = thisYear "5/26", "17:00"
      range = moment(start).twix end
      assertEqual 0, range.countInner("days")

    it "returns 1 if the range includes one full day", ->
      start = thisYear "5/24", "16:00"
      end = thisYear "5/26", "17:00"
      range = moment(start).twix end
      assertEqual 1, range.countInner("days")

    it "returns 2 if the range includes two full days", ->
      start = thisYear "5/23", "16:00"
      end = thisYear "5/26", "17:00"
      range = moment(start).twix end
      assertEqual 2, range.countInner("days")

    it "returns 1 for a one-day all-day event", ->
      start = thisYear "5/25"
      end = thisYear "5/25"
      range = moment(start).twix end, true
      assertEqual 1, range.countInner("days")

    it "returns 2 for a two-day all-day event", ->
      start = thisYear "5/25"
      end = thisYear "5/26"
      range = moment(start).twix end, true
      assertEqual 2, range.countInner("days")

describe "iterate()", ->

  describe "days", ->
    assertSameDay = (first, second) -> assertEqual true, first.isSame(second, "day")

    it "provides 1 day if the range includes 1 day", ->
      start = thisYear "5/25", "3:00"
      end = thisYear "5/25", "14:00"
      iter = start.twix(end).iterate("days")
      assertSameDay thisYear("5/25"), iter.next()
      assertEqual null, iter.next()

    it "provides 2 days if the range crosses midnight", ->
      start = thisYear "5/25", "16:00"
      end = thisYear "5/26", "3:00"
      iter = start.twix(end).iterate("days")
      assertSameDay start, iter.next()
      assertSameDay end, iter.next()
      assertEqual null, iter.next()

    it "provides 366 days if the range is a year", ->
      start = thisYear "5/25", "16:00"
      end = thisYear("5/25", "3:00").add 'years', 1
      iter = start.twix(end).iterate "days"
      results = while iter.hasNext()
        iter.next()
      assertEqual(366, results.length)

    it "provides 1 day for an all-day event", ->
      start = thisYear "5/25"
      end = thisYear "5/25"
      iter = start.twix(end, true).iterate "days"
      assertSameDay thisYear("5/25"), iter.next()
      assertEqual null, iter.next()

    it "doesn't generate extra days when there's a min time", ->
      start = thisYear "5/25", "16:00"
      end = thisYear "5/26", "3:00"
      iter = start.twix(end).iterate "days", 4
      assertSameDay thisYear("5/25"), iter.next()
      assertEqual null, iter.next()

    it "provides 1 day for all-day events when there's a min time", ->
      start = thisYear "5/25"
      end = thisYear "5/25"
      iter = start.twix(end, true).iterate "days", 4
      assertEqual true, iter.hasNext()
      assertSameDay start, iter.next()
      assertEqual false, iter.hasNext()
      assertEqual null, iter.next()

  describe "years", ->
    assertSameYear = (first, second) -> assertEqual true, first.isSame(second, "year")

    it "provides 1 year if the range happens inside a year", ->
      start = thisYear "5/25"
      end = thisYear "5/25"
      iter = start.twix(end).iterate("years")
      assertSameYear start, iter.next()
      assertEqual null, iter.next()

    it "provides 2 years if the range crosses Jan 1", ->
      start = thisYear "5/25"
      end = nextYear "5/26"
      iter = start.twix(end).iterate("years")
      assertSameYear start, iter.next()
      assertSameYear end, iter.next()
      assertEqual null, iter.next()

    #is this good behavior?
    it "doesn't generate extra years when there's a min time", ->
      start = thisYear "5/25", "16:00"
      end = nextYear "1/1", "3:00"
      range = moment(start).twix end
      iter = range.iterate "years", 4
      assertSameYear thisYear("5/25"), iter.next()
      assertEqual null, iter.next()

describe "iterateInner()", ->

  describe "days", ->

    assertSameDay = (first, second) -> assertEqual true, first.isSame(second, "day")

    it "is empty if the range starts and ends the same day", ->
      start = thisYear "5/25", "3:00"
      end = thisYear "5/25", "14:00"
      iter = start.twix(end).iterateInner("days")
      assertEqual false, iter.hasNext()
      assertEqual null, iter.next()

    it "is empty if the range doesn't contain a whole day", ->
      start = thisYear "5/25", "16:00"
      end = thisYear "5/26", "17:00"
      iter = start.twix(end).iterateInner("days")
      assertEqual false, iter.hasNext()
      assertEqual null, iter.next()

    it "provides 1 day if the range contains 1 full day", ->
      start = thisYear "5/24", "16:00"
      end = thisYear "5/26", "3:00"
      iter = start.twix(end).iterateInner("days")
      assertSameDay thisYear("5/25"), iter.next()
      assertEqual null, iter.next()

    it "provides 1 day for an all-day event", ->
      start = thisYear "5/25"
      end = thisYear "5/25"
      iter = start.twix(end, true).iterateInner "days"
      assertSameDay thisYear("5/25"), iter.next()
      assertEqual null, iter.next()

    it "provides 2 days for a two-day all-day event", ->
      start = thisYear "5/25"
      end = thisYear "5/26"
      iter = start.twix(end, true).iterateInner "days"
      assertEqual true, iter.hasNext()
      assertSameDay thisYear("5/25"), iter.next()
      assertEqual true, iter.hasNext()
      assertSameDay thisYear("5/26"), iter.next()
      assertEqual null, iter.next()

describe "humanizeLength()", ->
  describe "all-day events", ->
    it "formats single-day correctly", ->
      assertEqual("all day", new Twix("5/25/1982", "5/25/1982", true).humanizeLength())

    it "formats multiday correctly", ->
      assertEqual("3 days", new Twix("5/25/1982", "5/27/1982", true).humanizeLength())

  describe "non-all-day events", ->
    it "formats single-day correctly", ->
      assertEqual("4 hours", thatDay("12:00", "16:00").humanizeLength())

    it "formats multiday correctly", ->
      assertEqual("2 days", new Twix("5/25/1982", "5/27/1982").humanizeLength())

describe "asDuration()", ->
  it "returns a duration object", ->
    duration = yesterday().twix(tomorrow()).asDuration()
    assertEqual true, moment.isDuration(duration)
    assertEqual 2, duration.days()

describe "isPast()", ->
  describe "all-day events", ->
    it "returns true for days in the past", ->
      assertEqual true, yesterday().twix(yesterday(), true).isPast()

    it "returns false for today", ->
      today = moment().startOf 'day'
      assertEqual false, today.twix(today, true).isPast()

    it "returns false for days in the future", ->
      assertEqual false, tomorrow().twix(tomorrow(), true).isPast()

  describe "non-all-day events", ->
    it "returns true for the past", ->
      past = moment().subtract 'hours', 3
      nearerPast = moment().subtract 'hours', 2
      assertEqual true, past.twix(nearerPast).isPast()

    it "returns false for the future", ->
      future = moment().add 'hours', 2
      furtherFuture = moment().add 'hours', 3
      assertEqual false, future.twix(furtherFuture).isPast()

describe "isFuture()", ->
  describe "all-day events", ->
    it "returns false for days in the past", ->
      assertEqual false, yesterday().twix(yesterday(), true).isFuture()

    it "returns false for today", ->
      today = moment().startOf 'day'
      assertEqual false, today.twix(today, true).isFuture()

    it "returns true for days in the future", ->
      assertEqual true, tomorrow().twix(tomorrow(), true).isFuture()

  describe "non-all-day events", ->
    it "returns false for the past", ->
      past = moment().subtract 'hours', 3
      nearerPast = moment().subtract 'hours', 2
      assertEqual false, past.twix(nearerPast).isFuture()

    it "returns true for the future", ->
      future = moment().add 'hours', 2
      furtherFuture = moment().add 'hours', 3
      assertEqual true, future.twix(furtherFuture).isFuture()

describe "isCurrent()", ->
  describe "all-day events", ->
    it "returns false for days in the past", ->
      assertEqual false, yesterday().twix(yesterday(), true).isCurrent()

    it "returns true for today", ->
      today = moment().startOf 'day'
      assertEqual true, today.twix(today, true).isCurrent()

    it "returns false for days in the future", ->
      assertEqual false, tomorrow().twix(tomorrow(), true).isCurrent()

  describe "non-all-day events", ->
    it "returns false for the past", ->
      past = moment().subtract 'hours', 3
      nearerPast = moment().subtract 'hours', 2
      assertEqual false, past.twix(nearerPast).isCurrent()

    it "returns false for the future", ->
      future = moment().add 'hours', 2
      furtherFuture = moment().add 'hours', 3
      assertEqual false, future.twix(furtherFuture).isCurrent()

describe "contains()", ->

  describe "non-all-day", ->
    start = thisYear "5/25", "6:00"
    end = thisYear "5/25", "7:00"
    range = start.twix end

    it "returns true for moments inside the range", ->
      assertEqual true, range.contains(thisYear "5/25", "6:30")

    it "returns true for moments at the beginning of the range", ->
      assertEqual true, range.contains(start)

    it "returns true for moments at the end of the range", ->
      assertEqual true, range.contains(end)

    it "returns false for moments before the range", ->
      assertEqual false, range.contains(thisYear "5/25", "5:30")

    it "returns false for moments after the range", ->
      assertEqual false, range.contains(thisYear "5/25", "8:30")

  describe "all-day", ->
    start = thisYear "5/25"
    range = start.twix start, true

    it "returns true for moments inside the range", ->
      assertEqual true, range.contains(thisYear "5/25", "6:30")

    it "returns true for moments at the beginning of the range", ->
      assertEqual true, range.contains(start)

    it "returns true for moments at the end of the range", ->
      assertEqual true, range.contains(start.clone().endOf "day")

    it "returns false for moments before the range", ->
      assertEqual false, range.contains(thisYear "5/24")

    it "returns false for moments after the range", ->
      assertEqual false, range.contains(thisYear "5/26")

describe "overlaps()", ->

  assertOverlap = (first, second) -> assertOverlapness(true)(first, second)
  assertNoOverlap = (first, second) -> assertOverlapness(false)(first, second)

  assertOverlapness = (shouldOverlap) ->
    (first, second) ->
      assertEqual shouldOverlap, first.overlaps(second)
      assertEqual shouldOverlap, second.overlaps(first)

  someTime = thatDay "5:30", "8:30"
  someDays = new Twix("5/24/1982", "5/25/1982", true)

  describe "non-all-day events", ->

    it "returns false for a later event", ->
      assertNoOverlap someTime, thatDay "9:30", "11:30"

    it "returns false for an earlier event", ->
      assertNoOverlap someTime, thatDay "3:30", "4:30"

    it "returns true for a partially later event", ->
      assertOverlap someTime, thatDay "8:00", "11:30"

    it "returns true for a partially earlier event", ->
      assertOverlap someTime, thatDay "4:30", "6:30"

    it "returns true for an engulfed event", ->
      assertOverlap someTime, thatDay "6:30", "7:30"

    it "returns true for an engulfing event", ->
      assertOverlap someTime, thatDay "4:30", "9:30"

  describe "one all-day event", ->
    it "returns true for a partially later event", ->
      assertOverlap thatDay(), new Twix("5/25/1982 20:00", "5/26/1982 5:00")

    it "returns true for a partially earlier event", ->
      assertOverlap thatDay(), new Twix("5/24/1982", "20:00", "5/25/1982 7:00")

    it "returns true for an engulfed event", ->
      assertOverlap thatDay(), someTime

    it "returns true for an engulfing event", ->
      assertOverlap thatDay(), new Twix("5/24/1982 20:00", "5/26/1982 5:00")

  describe "two all-day events", ->
    it "returns false for a later event", ->
      assertNoOverlap someDays, new Twix("5/26/1982", "5/27/1982", true)

    it "returns false for an earlier event", ->
      assertNoOverlap someDays, new Twix("5/22/1982", "5/23/1982", true)

    it "returns true for a partially later event", ->
      assertOverlap someDays, new Twix("5/24/1982", "5/26/1982", true)

    it "returns true for a partially earlier event", ->
      assertOverlap someDays, new Twix("5/22/1982", "5/24/1982", true)

    it "returns true for an engulfed event", ->
      assertOverlap someDays, new Twix("5/25/1982", "5/25/1982", true)

    it "returns true for an engulfing event", ->
      assertOverlap someDays, new Twix("5/22/1982", "5/28/1982", true)

describe "engulfs()", ->

  assertEngulfing = (first, second) -> assertEqual true, first.engulfs(second)
  assertNotEngulfing = (first, second) -> assertEqual false, first.engulfs(second)

  someTime = thatDay "5:30", "8:30"
  someDays = new Twix("5/24/1982", "5/25/1982", true)

  describe "non-all-day events", ->

    it "returns false for a later event", ->
      assertNotEngulfing someTime, thatDay "9:30", "11:30"

    it "returns false for an earlier event", ->
      assertNotEngulfing someTime, thatDay "3:30", "4:30"

    it "returns true for a partially later event", ->
      assertNotEngulfing someTime, thatDay "8:00", "11:30"

    it "returns true for a partially earlier event", ->
      assertNotEngulfing someTime, thatDay "4:30", "6:30"

    it "returns true for an engulfed event", ->
      assertEngulfing someTime, thatDay "6:30", "7:30"

    it "returns true for an engulfing event", ->
      assertNotEngulfing someTime, thatDay "4:30", "9:30"

  describe "one all-day event", ->
    it "returns true for a partially later event", ->
      assertNotEngulfing thatDay(), new Twix("5/25/1982 20:00", "5/26/1982 5:00")

    it "returns true for a partially earlier event", ->
      assertNotEngulfing thatDay(), new Twix("5/24/1982", "20:00", "5/25/1982 7:00")

    it "returns true for an engulfed event", ->
      assertEngulfing thatDay(), someTime

    it "returns true for an engulfing event", ->
      assertNotEngulfing thatDay(), new Twix("5/24/1982 20:00", "5/26/1982 5:00")

  describe "two all-day events", ->
    it "returns false for a later event", ->
      assertNotEngulfing someDays, new Twix("5/26/1982", "5/27/1982", true)

    it "returns false for an earlier event", ->
      assertNotEngulfing someDays, new Twix("5/22/1982", "5/23/1982", true)

    it "returns true for a partially later event", ->
      assertNotEngulfing someDays, new Twix("5/24/1982", "5/26/1982", true)

    it "returns true for a partially earlier event", ->
      assertNotEngulfing someDays, new Twix("5/22/1982", "5/24/1982", true)

    it "returns true for an engulfed event", ->
      assertEngulfing someDays, new Twix("5/25/1982", "5/25/1982", true)

    it "returns true for an engulfing event", ->
      assertNotEngulfing someDays, new Twix("5/22/1982", "5/28/1982", true)

describe "merge()", ->

  someTime = thatDay "5:30", "8:30"
  someDays = new Twix "5/24/1982", "5/25/1982", true

  describe "non-all-day events", ->

    it "spans a later time", ->
      assertTwixEqual thatDay("5:30", "11:30"), someTime.merge(thatDay "9:30", "11:30")

    it "spans an earlier time", ->
      assertTwixEqual thatDay("3:30", "8:30"), someTime.merge(thatDay "3:30", "4:30")

    it "spans a partially later event", ->
      assertTwixEqual thatDay("5:30", "11:30"), someTime.merge(thatDay "8:00", "11:30")

    it "spans a partially earlier event", ->
      assertTwixEqual thatDay("4:30", "8:30"), someTime.merge(thatDay "4:30", "6:30")

    it "isn't affected by engulfed events", ->
      assertTwixEqual someTime, someTime.merge(thatDay "6:30", "7:30")

    it "becomes an engulfing event", ->
      assertTwixEqual thatDay("4:30", "9:30"), someTime.merge(thatDay "4:30", "9:30")

  describe "one all-day event", ->
    it "spans a later time", ->
      assertTwixEqual new Twix("5/24/1982 00:00", "5/26/1982 7:00"), someDays.merge(new Twix("5/24/1982 20:00", "5/26/1982 7:00"))

    it "spans an earlier time", ->
      assertTwixEqual new Twix("5/23/1982 8:00", moment("5/25/1982").endOf('day')), someDays.merge(new Twix("5/23/1982 8:00", "5/25/1982 7:00"))

    #i'm tempted to just say this is wrong...shouldn't it get to stay an all-day event?
    it "isn't affected by engulfing events", ->
      assertTwixEqual new Twix("5/24/1982 00:00", moment("5/25/1982").endOf('day')), someDays.merge(someTime)

    it "becomes an engulfing event", ->
      assertTwixEqual new Twix("5/23/1982 20:00", "5/26/1982 8:30"), someDays.merge(new Twix("5/23/1982 20:00", "5/26/1982 8:30"))

  describe "two all-day events", ->

    it "spans a later time", ->
      assertTwixEqual new Twix("5/24/1982", "5/28/1982", true), someDays.merge(new Twix("5/27/1982", "5/28/1982", true))

    it "spans an earlier time", ->
      assertTwixEqual new Twix("5/21/1982", "5/25/1982", true), someDays.merge(new Twix("5/21/1982", "5/22/1982", true))

    it "spans a partially later time", ->
      assertTwixEqual new Twix("5/24/1982", "5/26/1982", true), someDays.merge(new Twix("5/25/1982", "5/26/1982", true))

    it "spans a partially earlier time", ->
      assertTwixEqual new Twix("5/23/1982", "5/25/1982", true), someDays.merge(new Twix("5/23/1982", "5/25/1982", true))

    it "isn't affected by engulfing events", ->
      assertTwixEqual someDays, someDays.merge(thatDay())

    it "becomes an engulfing event", ->
      assertTwixEqual someDays, thatDay().merge(someDays)

describe "simpleFormat()", ->
  it "it provides a simple string when provided no options", ->
    s = yesterday().twix(tomorrow()).simpleFormat()
    assertEqual true, s.indexOf(" - ") > -1

  it "specifies '(all day)' if it's all day", ->
    s = yesterday().twix(tomorrow(), true).simpleFormat()
    assertEqual true, s.indexOf("(all day)") > -1

  it "accepts moment formatting options", ->
    s = thisYear("10/14").twix(thisYear("10/14")).simpleFormat "MMMM"
    assertEqual "October - October", s

  it "accepts an allDay option", ->
    s = thisYear("5/25").twix(thisYear("5/26"), true).simpleFormat null, allDay: "(wayo wayo)"
    assertEqual true, s.indexOf("(wayo wayo)") > -1

  it "removes the all day text if allDay is null", ->
    s = thisYear("5/25").twix(thisYear("5/26"), true).simpleFormat null, allDay: null
    assertEqual true, s.indexOf("(all day)") == -1

describe "format()", ->

  test = (name, t) -> it name, ->
    twix = new Twix(t.start, t.end, t.allDay)
    assertEqual(t.result, twix.format(t.options))

  describe "simple ranges", ->
    test "different year, different day shows everything",
      start: "5/25/1982 5:30 AM"
      end: "5/26/1983 3:30 PM"
      result: 'May 25, 1982, 5:30 AM - May 26, 1983, 3:30 PM'

    test "this year, different day skips year",
      start: thisYear("5/25", "5:30 AM")
      end: thisYear("5/26", "3:30 PM")
      result: 'May 25, 5:30 AM - May 26, 3:30 PM'

    test "this year, different day shows year if requested",
      start: thisYear("5/25", "5:30 AM")
      end: thisYear("5/26", "3:30 PM")
      options: {implicitYear: false}
      result: "May 25, 5:30 AM - May 26, 3:30 PM, #{new Date().getFullYear() }"

    test "same day, different times shows date once",
      start: "5/25/1982 5:30 AM"
      end: "5/25/1982 3:30 PM"
      result: 'May 25, 1982, 5:30 AM - 3:30 PM'

    test "same day, different times, same meridian shows date and meridiem once",
      start: "5/25/1982 5:30 AM"
      end: "5/25/1982 6:30 AM"
      result: 'May 25, 1982, 5:30 - 6:30 AM'

    test "custom month format for regular event",
      start: "8/25/2010 5:30 AM"
      end: "8/25/2010 6:30 AM"
      options: {monthFormat: "MMMM"}
      result: 'August 25, 2010, 5:30 - 6:30 AM'

    test "custom month format for all day event",
      start: "8/25/2010"
      end: "8/25/2010"
      allDay: true
      options: {monthFormat: "MMMM"}
      result: 'August 25, 2010'

  describe "rounded times", ->
    test "round hour doesn't show :00",
      start: "5/25/1982 5:00 AM"
      end: "5/25/1982 7:00 AM"
      result: "May 25, 1982, 5 - 7 AM"

    test "mixed times still shows :30",
      start: "5/25/1982 5:00 AM"
      end: "5/25/1982 5:30 AM"
      result: "May 25, 1982, 5 - 5:30 AM"

  describe "implicit minutes", ->
    test "still shows the :00",
      start: thisYear "5/25", "5:00 AM"
      end: thisYear "5/25", "7:00 AM"
      options: {implicitMinutes: false}
      result: "May 25, 5:00 - 7:00 AM"

  describe "all day events", ->

    test "one day has no range",
      start: "8/25/2010"
      end: "8/25/2010"
      allDay: true
      result: "Aug 25, 2010"

    test "same month says month on one side",
      start: thisYear("5/25")
      end: thisYear("5/26")
      allDay: true
      result: "May 25 - 26"

    test "same month says month on one side, with year if requested",
      start: thisYear("5/25")
      end: thisYear("5/26")
      allDay: true
      options: {implicitYear: false}
      result: "May 25 - 26, #{ (new Date).getFullYear() }"

    test "different month shows both",
      start: thisYear("5/25")
      end: thisYear("6/1")
      allDay: true
      result: "May 25 - Jun 1"

    test "different month shows both, with year if requested",
      start: thisYear("5/25")
      end: thisYear("6/1")
      allDay: true
      options: {implicitYear: false}
      result: "May 25 - Jun 1, #{ (new Date).getFullYear() }"

    test "explicit year shows the year once",
      start: "5/25/1982"
      end: "5/26/1982"
      allDay: true,
      result: "May 25 - 26, 1982"

    test "different year shows the year twice",
      start: "5/25/1982"
      end: "5/25/1983"
      allDay: true
      result: "May 25, 1982 - May 25, 1983"

    test "different year different month shows the month at the end",
      start: "5/25/1982"
      end: "6/1/1983"
      allDay: true
      result: "May 25, 1982 - Jun 1, 1983"

    test "explicit allDay",
      start: "5/25/1982"
      end: "5/25/1982"
      allDay: true
      options: {explicitAllDay: true}
      result: "all day May 25, 1982"

  describe "no single dates", ->
    test "shouldn't show dates for intraday",
      start: "5/25/2010 5:30 AM"
      end: "5/25/2010 6:30 AM"
      options: {showDate: false}
      result: "5:30 - 6:30 AM"

    test "should show the dates for multiday",
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/27", "6:30 AM"
      options: {showDate : false}
      result: "May 25, 5:30 AM - May 27, 6:30 AM"

    test "should just say 'all day' for all day events",
      start: thisYear("5/25")
      end: thisYear("5/25")
      options: {showDate : false}
      allDay: true
      result: "all day"

  describe "ungroup meridiems", ->
    test "should put meridiems on both sides",
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/25", "7:30 AM"
      options: {groupMeridiems: false}
      result: "May 25, 5:30 AM - 7:30 AM"

    test "even with abbreviated hours",
      start: thisYear "5/25", "7:00 PM"
      end: thisYear "5/25", "9:00 PM"
      options: {groupMeridiems: false}
      result: "May 25, 7 PM - 9 PM"

  describe "no meridiem spaces", ->
    test "should skip the meridiem space",
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/25", "7:30 AM"
      options: {spaceBeforeMeridiem: false, groupMeridiems: false}
      result: "May 25, 5:30AM - 7:30AM"

  describe "24 hours", ->
    test "shouldn't show meridians",
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/25", "7:30 PM"
      options: {twentyFourHour: true},
      result: "May 25, 5:30 - 19:30"

    test "always shows the :00",
      start: thisYear "5/25", "12:00"
      end: thisYear "5/25", "15:00"
      options: {twentyFourHour: true},
      result: "May 25, 12:00 - 15:00"

  describe "show day of week", ->

    test "should show day of week",
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/28", "7:30 PM"
      options: {showDayOfWeek: true},
      result: "Sat May 25, 5:30 AM - Tue May 28, 7:30 PM"

    test "should show day of week, specify day of week format",
      start: thisYear "8/25", "5:30 AM"
      end: thisYear "8/28", "7:30 PM"
      options: {showDayOfWeek: true, weekdayFormat: 'dddd'}
      result: "Sunday Aug 25, 5:30 AM - Wednesday Aug 28, 7:30 PM"

    test "collapses show day of week",
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/25", "7:30 PM"
      options: {showDayOfWeek: true},
      result: "Sat May 25, 5:30 AM - 7:30 PM"

    test "doesn't collapse with one week of separation",
      start: thisYear "5/25"
      end: thisYear "6/1"
      allDay: true
      options: {showDayOfWeek: true},
      result: "Sat May 25 - Sat Jun 1"

  describe "goes into the morning", ->

    test "elides late nights",
      start: "5/25/1982 5:00 PM"
      end: "5/26/1982 2:00 AM"
      options: {lastNightEndsAt: 5},
      result: "May 25, 1982, 5 PM - 2 AM"

    test "keeps late mornings",
      start: "5/25/1982 5:00 PM"
      end: "5/26/1982 10:00 AM"
      options: {lastNightEndsAt: 5},
      result: "May 25, 5 PM - May 26, 10 AM, 1982"

    test "morning start is adjustable",
      start: "5/25/1982 5:00 PM"
      end: "5/26/1982 10:00 AM"
      options: {lastNightEndsAt: 11},
      result: "May 25, 1982, 5 PM - 10 AM"

    test "doesn't elide if you start in the AM",
      start: "5/25/1982 5:00 AM"
      end: "5/26/1982 4:00 AM"
      options: {lastNightEndsAt: 5},
      result: "May 25, 5 AM - May 26, 4 AM, 1982"

    describe "and we're trying to hide the date", ->

      test "elides the date too for early mornings",
        start: "5/25/1982 5:00 PM"
        end: "5/26/1982 2:00 AM"
        options: {lastNightEndsAt: 5, showDate: false},
        result: "5 PM - 2 AM"

      test "doesn't elide if the morning ends late",
        start: "5/25/1982 5:00 PM"
        end: "5/26/1982 10:00 AM"
        options: {lastNightEndsAt: 5},
        result: "May 25, 5 PM - May 26, 10 AM, 1982"
