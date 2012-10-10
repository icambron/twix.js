if typeof module != "undefined"
  moment = require("moment")
  assertEqual = require('assert').equal
  assertDeepEqual = require('assert').deepEqual
  Twix = require("../../bin/twix")
else
  moment = window.moment
  Twix = window.Twix
  assertEqual = (a, b) -> throw new Error("Found #{b}, expected #{a}") unless a == b
  assertDeepEqual = (a, b) -> throw new Error("Found #{b}, expected #{a}") unless a.equals(b)

thisYear = (partial, time) ->
  fullDate = "#{partial}/#{moment().year()}"
  fullDate += " #{time}" if time
  moment fullDate

yesterday = -> moment().subtract('days', 1).sod()
tomorrow = -> moment().add('days', 1).sod()

thatDay = (start, end) ->
  if start
    new Twix "5/25/1982 #{start}", "5/25/1982 #{end}"
  else
    new Twix "5/25/1982", "5/25/1982", true

describe "plugin", ->
  it "works", ->
    assertEqual "function", typeof(moment.twix)
    assertDeepEqual new Twix("5/25/1982", "5/25/1983", true), moment.twix("5/25/1982", "5/25/1983", true)

describe "sameYear()", ->

  it "returns true if they're the same year", ->
    assertEqual true, new Twix("5/25/1982", "10/14/1982").sameYear()

  it "returns false if they're different years", ->
    assertEqual false, new Twix("5/25/1982", "10/14/1983").sameYear()

describe "sameDay()", ->

  it "returns true if they're the same day", ->
    assertEqual true, new Twix("5/25/1982 5:30 AM", "5/25/1982 7:30 PM").sameDay()

  it "returns false if they're different days day", ->
    assertEqual false, new Twix("5/25/1982 5:30 AM", "5/26/1982 7:30 PM").sameDay()

  it "returns true they're in different UTC days but the same local days", ->
    assertEqual true, new Twix("5/25/1982 5:30 AM", "5/25/1982 11:30 PM").sameDay()

describe "countDays()", ->

  it "inside one day returns 1", ->
    start = thisYear "5/25", "3:00"
    end = thisYear "5/25", "14:00"
    range = new Twix start, end
    assertEqual 1, range.countDays()

  it "returns 2 if the range crosses midnight", ->
    start = thisYear "5/25", "16:00"
    end = thisYear "5/26", "3:00"
    range = new Twix start, end
    assertEqual 2, range.countDays()

  it "works fine for all-day events", ->
    start = thisYear "5/25"
    end = thisYear "5/26"
    range = new Twix start, end, true
    assertEqual 2, range.countDays()

describe "daysIn()", ->

  assertSameDay = (first, second) ->
    assertEqual first.year(), second.year()
    assertEqual first.month(), second.month()
    assertEqual first.date(), second.date()

  it "provides 1 day if the range includes 1 day", ->
    start = thisYear "5/25", "3:00"
    end = thisYear "5/25", "14:00"
    range = new Twix start, end

    iter = range.daysIn()
    next = iter.next()
    assertSameDay thisYear("5/25"), next
    assertEqual null, iter.next()

  it "provides 2 days if the range crosses midnight", ->
    start = thisYear "5/25", "16:00"
    end = thisYear "5/26", "3:00"
    range = new Twix start, end

    iter = range.daysIn()
    assertSameDay thisYear("5/25"), iter.next()
    assertSameDay thisYear("5/26"), iter.next()
    assertEqual null, iter.next()

  it "provides 366 days if the range is a year", ->
    start = thisYear "5/25", "16:00"
    end = thisYear("5/25", "3:00").add('years', 1)
    iter = new Twix(start, end).daysIn()
    results = while iter.hasNext()
      iter.next()
    assertEqual(366, results.length)

  it "provides 1 day for an all-day event", ->
    start = thisYear "5/25"
    end = thisYear "5/25"
    iter = new Twix(start, end, true).daysIn()
    assertSameDay thisYear("5/25"), iter.next()
    assertEqual null, iter.next()

  it "doesn't generate extra days when there's a min time", ->
    start = thisYear "5/25", "16:00"
    end = thisYear "5/26", "3:00"
    range = new Twix start, end

    iter = range.daysIn(4)
    assertSameDay thisYear("5/25"), iter.next()
    assertEqual null, iter.next()

  it "provides 1 day for all-day events when there's a min time", ->
    start = thisYear "5/25"
    end = thisYear "5/25"
    iter = new Twix(start, end, true).daysIn(4)
    assertEqual true, iter.hasNext()
    assertSameDay thisYear("5/25"), iter.next()
    assertEqual false, iter.hasNext()
    assertEqual null, iter.next()

describe "duration()", ->
  describe "all-day events", ->
    it "formats single-day correctly", ->
      assertEqual("all day", new Twix("5/25/1982", "5/25/1982", true).duration())

    it "formats multiday correctly", ->
      assertEqual("3 days", new Twix("5/25/1982", "5/27/1982", true).duration())

  describe "non-all-day events", ->
    it "formats single-day correctly", ->
      assertEqual("4 hours", thatDay("12:00", "16:00").duration())

    it "formats multiday correctly", ->
      assertEqual("2 days", new Twix("5/25/1982", "5/27/1982").duration())

describe "past()", ->
  describe "all-day events", ->
    it "returns true for days in the past", ->
      assertEqual(true, new Twix(yesterday(), yesterday(), true).past())

    it "returns false for today", ->
      assertEqual(false, new Twix(moment().sod(), moment().sod(), true).past())

    it "returns false for days in the future", ->
      assertEqual(false, new Twix(tomorrow(), tomorrow(), true).past())

  describe "non-all-day events", ->
    it "returns true for the past", ->
      assertEqual(true, new Twix(moment().subtract('hours', 3), moment().subtract('hours', 2)).past())

    it "returns false for the future", ->
      assertEqual(false, new Twix(moment().add('hours', 2), moment().add('hours', 3)).past())

describe "overlaps", ->

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

describe "engulfs", ->

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
      assertDeepEqual thatDay("5:30", "11:30"), someTime.merge(thatDay "9:30", "11:30")

    it "spans an earlier time", ->
      assertDeepEqual thatDay("3:30", "8:30"), someTime.merge(thatDay "3:30", "4:30")

    it "spans a partially later event", ->
      assertDeepEqual thatDay("5:30", "11:30"), someTime.merge(thatDay "8:00", "11:30")

    it "spans a partially earlier event", ->
      assertDeepEqual thatDay("4:30", "8:30"), someTime.merge(thatDay "4:30", "6:30")

    it "isn't affected by engulfed events", ->
      assertDeepEqual someTime, someTime.merge(thatDay "6:30", "7:30")

    it "becomes an engulfing event", ->
      assertDeepEqual thatDay("4:30", "9:30"), someTime.merge(thatDay "4:30", "9:30")

  describe "one all-day event", ->
    it "spans a later time", ->
      assertDeepEqual new Twix("5/24/1982 00:00", "5/26/1982 7:00"), someDays.merge(new Twix("5/24/1982 20:00", "5/26/1982 7:00"))

    it "spans an earlier time", ->
      assertDeepEqual new Twix("5/23/1982 8:00", moment("5/25/1982").eod()), someDays.merge(new Twix("5/23/1982 8:00", "5/25/1982 7:00"))

    #i'm tempted to just say this is wrong...shouldn't it get to stay an all-day event?
    it "isn't affected by engulfing events", ->
      assertDeepEqual new Twix("5/24/1982 00:00", moment("5/25/1982").eod()), someDays.merge(someTime)

    it "becomes an engulfing event", ->
      assertDeepEqual new Twix("5/23/1982 20:00", "5/26/1982 8:30"), someDays.merge(new Twix("5/23/1982 20:00", "5/26/1982 8:30"))

  describe "two all-day events", ->

    it "spans a later time", ->
      assertDeepEqual new Twix("5/24/1982", "5/28/1982", true), someDays.merge(new Twix("5/27/1982", "5/28/1982", true))

    it "spans an earlier time", ->
      assertDeepEqual new Twix("5/21/1982", "5/25/1982", true), someDays.merge(new Twix("5/21/1982", "5/22/1982", true))

    it "spans a partially later time", ->
      assertDeepEqual new Twix("5/24/1982", "5/26/1982", true), someDays.merge(new Twix("5/25/1982", "5/26/1982", true))

    it "spans a partially earlier time", ->
      assertDeepEqual new Twix("5/23/1982", "5/25/1982", true), someDays.merge(new Twix("5/23/1982", "5/25/1982", true))

    it "isn't affected by engulfing events", ->
      assertDeepEqual someDays, someDays.merge(thatDay())

    it "becomes an engulfing event", ->
      assertDeepEqual someDays, thatDay().merge(someDays)

describe "format()", ->

  test = (name, t) -> it name, ->
    twix = new Twix(t.start, t.end, t.allDay)
    assertEqual(t.result, twix.format(t.options))

  describe "simple ranges", ->
    test "different year, different day shows everything"
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
      result: "May 25, 5:30 AM - May 26, 3:30 PM, #{ (new Date).getFullYear() }"

    test "same day, different times shows date once",
      start: "5/25/1982 5:30 AM"
      end: "5/25/1982 3:30 PM"
      result: 'May 25, 1982, 5:30 AM - 3:30 PM'

    test "same day, different times, same meridian shows date and meridiem once",
      start: "5/25/1982 5:30 AM"
      end: "5/25/1982 6:30 AM"
      result: 'May 25, 1982, 5:30 - 6:30 AM'

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
      start: "5/25/2010"
      end: "5/25/2010"
      allDay: true
      result: "May 25, 2010"

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

    test "different year different month shows the month at the end"
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
    test "should skip the meridiem space"
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/25", "7:30 AM"
      options: {spaceBeforeMeridiem: false, groupMeridiems: false}
      result: "May 25, 5:30AM - 7:30AM"

  describe "24 hours", ->
    test "shouldn't show meridians"
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/25", "7:30 PM"
      options: {twentyFourHour: true},
      result: "May 25, 5:30 - 19:30"

    test "always shows the :00"
      start: thisYear "5/25", "12:00"
      end: thisYear "5/25", "15:00"
      options: {twentyFourHour: true},
      result: "May 25, 12:00 - 15:00"

  describe "show day of week", ->

    test "should show day of week"
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/28", "7:30 PM"
      options: {showDayOfWeek: true},
      result: "Fri May 25, 5:30 AM - Mon May 28, 7:30 PM"

    test "collapses show day of week"
      start: thisYear "5/25", "5:30 AM"
      end: thisYear "5/25", "7:30 PM"
      options: {showDayOfWeek: true},
      result: "Fri May 25, 5:30 AM - 7:30 PM"

    test "doesn't collapse with one week of separation"
      start: thisYear "5/25"
      end: thisYear "6/1"
      allDay: true
      options: {showDayOfWeek: true},
      result: "Fri May 25 - Fri Jun 1"

  describe "goes into the morning", ->

    test "elides late nights"
      start: "5/25/1982 5:00 PM"
      end: "5/26/1982 2:00 AM"
      options: {lastNightEndsAt: 5},
      result: "May 25, 1982, 5 PM - 2 AM"

    test "keeps late mornings"
      start: "5/25/1982 5:00 PM"
      end: "5/26/1982 10:00 AM"
      options: {lastNightEndsAt: 5},
      result: "May 25, 5 PM - May 26, 10 AM, 1982"

    test "morning start is adjustable"
      start: "5/25/1982 5:00 PM"
      end: "5/26/1982 10:00 AM"
      options: {lastNightEndsAt: 11},
      result: "May 25, 1982, 5 PM - 10 AM"

    test "doesn't elide if you start in the AM"
      start: "5/25/1982 5:00 AM"
      end: "5/26/1982 4:00 AM"
      options: {lastNightEndsAt: 5},
      result: "May 25, 5 AM - May 26, 4 AM, 1982"

    describe "and we're trying to hide the date", ->

      test "elides the date too for early mornings"
        start: "5/25/1982 5:00 PM"
        end: "5/26/1982 2:00 AM"
        options: {lastNightEndsAt: 5, showDate: false},
        result: "5 PM - 2 AM"

      test "doesn't elide if the morning ends late"
        start: "5/25/1982 5:00 PM"
        end: "5/26/1982 10:00 AM"
        options: {lastNightEndsAt: 5},
        result: "May 25, 5 PM - May 26, 10 AM, 1982"
