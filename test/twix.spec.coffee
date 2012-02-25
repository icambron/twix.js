if typeof module != "undefined"
  moment = require("moment")
  assertEqual = require('assert').equal
  Twix = require("../../bin/twix")
else 
  moment = window.moment
  Twix = window.Twix
  assertEqual = (a, b) -> throw new Error("Found #{b}, expected #{a}") unless a == b

thisYear = (partial, time) -> 
  fullDate = "#{partial}/#{moment().year()}"
  fullDate += " #{time}" if time
  moment fullDate

yesterday = -> moment().subtract('days', 1).sod()
tomorrow = -> moment().add('days', 1).sod()

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
    assertSameDay thisYear("5/25"), iter.next()
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

describe "duration()", ->
  describe "all-day events", -> 
    it "formats single-day correctly", ->
      assertEqual("all day", new Twix("5/25/1982", "5.25/1982", true).duration())

    it "formats multiday correctly", ->
      assertEqual("3 days", new Twix("5/25/1982", "5/27/1982", true).duration())
  
  describe "non-all-day events", ->
    it "formats single-day correctly", ->
      assertEqual("4 hours", new Twix("5/25/1982 12:00", "5/25/1982 16:00").duration())

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
    
    test "different month shows both",
      start: thisYear("5/25")
      end: thisYear("6/1")
      allDay: true
      result: "May 25 - Jun 1"

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