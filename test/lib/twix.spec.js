(function() {
  var Twix, assertEqual, moment, thisYear;

  if (typeof module !== "undefined") {
    moment = require("moment");
    assertEqual = require('assert').equal;
    Twix = require("../../lib/twix");
  } else {
    moment = window.moment;
    Twix = window.Twix;
    assertEqual = function(a, b) {
      if (a !== b) throw new Error("Found " + b + ", expected " + a);
    };
  }

  thisYear = function(partial, time) {
    var fullDate;
    fullDate = "" + partial + "/" + (moment().year());
    if (time) fullDate += " " + time;
    return moment(fullDate);
  };

  describe("format()", function() {
    var test;
    test = function(name, t) {
      return it(name, function() {
        var twix;
        twix = new Twix(t.start, t.end, t.allDay);
        return assertEqual(t.result, twix.format(t.options));
      });
    };
    describe("simple ranges", function() {
      test("different year, different day shows everything", {
        start: "5/25/1982 5:30 AM",
        end: "5/26/1983 3:30 PM",
        result: 'May 25, 1982, 5:30 AM - May 26, 1983, 3:30 PM'
      });
      test("this year, different day skips year", {
        start: thisYear("5/25", "5:30 AM"),
        end: thisYear("5/26", "3:30 PM"),
        result: 'May 25, 5:30 AM - May 26, 3:30 PM'
      });
      test("same day, different times shows date once", {
        start: "5/25/1982 5:30 AM",
        end: "5/25/1982 3:30 PM",
        result: 'May 25, 1982, 5:30 AM - 3:30 PM'
      });
      return test("same day, different times, same meridian shows date and meridiem once", {
        start: "5/25/1982 5:30 AM",
        end: "5/25/1982 6:30 AM",
        result: 'May 25, 1982, 5:30 - 6:30 AM'
      });
    });
    describe("rounded times", function() {
      test("round hour doesn't show :00", {
        start: "5/25/1982 5:00 AM",
        end: "5/25/1982 7:00 AM",
        result: "May 25, 1982, 5 - 7 AM"
      });
      return test("mixed times still shows :30", {
        start: "5/25/1982 5:00 AM",
        end: "5/25/1982 5:30 AM",
        result: "May 25, 1982, 5 - 5:30 AM"
      });
    });
    describe("implicit minutes", function() {
      return test("still shows the :00", {
        start: thisYear("5/25", "5:00 AM"),
        end: thisYear("5/25", "7:00 AM"),
        options: {
          implicitMinutes: false
        },
        result: "May 25, 5:00 - 7:00 AM"
      });
    });
    describe("all day events", function() {
      test("one day has no range", {
        start: "5/25/2010",
        end: "5/25/2010",
        allDay: true,
        result: "May 25, 2010"
      });
      test("same month says month on one side", {
        start: thisYear("5/25"),
        end: thisYear("5/26"),
        allDay: true,
        result: "May 25 - 26"
      });
      test("different month shows both", {
        start: thisYear("5/25"),
        end: thisYear("6/1"),
        allDay: true,
        result: "May 25 - Jun 1"
      });
      test("explicit year shows the year once", {
        start: "5/25/1982",
        end: "5/26/1982",
        allDay: true,
        result: "May 25 - 26, 1982"
      });
      test("different year shows the year twice", {
        start: "5/25/1982",
        end: "5/25/1983",
        allDay: true,
        result: "May 25, 1982 - May 25, 1983"
      });
      return test("different year different month shows the month at the end", {
        start: "5/25/1982",
        end: "6/1/1983",
        allDay: true,
        result: "May 25, 1982 - Jun 1, 1983"
      });
    });
    describe("no single dates", function() {
      test("shouldn't show dates for intraday", {
        start: "5/25/2010 5:30 AM",
        end: "5/25/2010 6:30 AM",
        options: {
          showDate: false
        },
        result: "5:30 - 6:30 AM"
      });
      test("should show the dates for multiday", {
        start: thisYear("5/25", "5:30 AM"),
        end: thisYear("5/27", "6:30 AM"),
        options: {
          showDate: false
        },
        result: "May 25, 5:30 AM - May 27, 6:30 AM"
      });
      return test("should just say 'all day' for all day events", {
        start: thisYear("5/25"),
        end: thisYear("5/25"),
        options: {
          showDate: false
        },
        allDay: true,
        result: "All day"
      });
    });
    describe("ungroup meridiems", function() {
      test("should put meridiems on both sides", {
        start: thisYear("5/25", "5:30 AM"),
        end: thisYear("5/25", "7:30 AM"),
        options: {
          groupMeridiems: false
        },
        result: "May 25, 5:30 AM - 7:30 AM"
      });
      return test("even with abbreviated hours", {
        start: thisYear("5/25", "7:00 PM"),
        end: thisYear("5/25", "9:00 PM"),
        options: {
          groupMeridiems: false
        },
        result: "May 25, 7 PM - 9 PM"
      });
    });
    describe("no meridiem spaces", function() {
      return test("should skip the meridiem space", {
        start: thisYear("5/25", "5:30 AM"),
        end: thisYear("5/25", "7:30 AM"),
        options: {
          spaceBeforeMeridiem: false,
          groupMeridiems: false
        },
        result: "May 25, 5:30AM - 7:30AM"
      });
    });
    describe("24 hours", function() {
      test("shouldn't show meridians", {
        start: thisYear("5/25", "5:30 AM"),
        end: thisYear("5/25", "7:30 PM"),
        options: {
          twentyFourHour: true
        },
        result: "May 25, 5:30 - 19:30"
      });
      return test("always shows the :00", {
        start: thisYear("5/25", "12:00"),
        end: thisYear("5/25", "15:00"),
        options: {
          twentyFourHour: true
        },
        result: "May 25, 12:00 - 15:00"
      });
    });
    return describe("show day of week", function() {
      test("should show day of week", {
        start: thisYear("5/25", "5:30 AM"),
        end: thisYear("5/28", "7:30 PM"),
        options: {
          showDayOfWeek: true
        },
        result: "Fri May 25, 5:30 AM - Mon May 28, 7:30 PM"
      });
      test("collapses show day of week", {
        start: thisYear("5/25", "5:30 AM"),
        end: thisYear("5/25", "7:30 PM"),
        options: {
          showDayOfWeek: true
        },
        result: "Fri May 25, 5:30 AM - 7:30 PM"
      });
      return test("doesn't collapse with one week of separation", {
        start: thisYear("5/25"),
        end: thisYear("6/1"),
        allDay: true,
        options: {
          showDayOfWeek: true
        },
        result: "Fri May 25 - Fri Jun 1"
      });
    });
  });

  describe("sameYear()", function() {
    it("returns true if they're the same year", function() {
      return assertEqual(true, new Twix("5/25/1982", "10/14/1982").sameYear());
    });
    return it("returns false if they're different years", function() {
      return assertEqual(false, new Twix("5/25/1982", "10/14/1983").sameYear());
    });
  });

  describe("sameDay()", function() {
    it("returns true if they're the same day", function() {
      return assertEqual(true, new Twix("5/25/1982 5:30 AM", "5/25/1982 7:30 PM").sameDay());
    });
    it("returns false if they're different days day", function() {
      return assertEqual(false, new Twix("5/25/1982 5:30 AM", "5/26/1982 7:30 PM").sameDay());
    });
    return it("returns true they're in different UTC days but the same local days", function() {
      return assertEqual(true, new Twix("5/25/1982 5:30 AM", "5/25/1982 11:30 PM").sameDay());
    });
  });

  describe("countDays()", function() {
    it("inside one day returns 1", function() {
      var end, range, start;
      start = thisYear("5/25", "3:00");
      end = thisYear("5/25", "14:00");
      range = new Twix(start, end);
      return assertEqual(1, range.countDays());
    });
    it("returns 2 if the range crosses midnight", function() {
      var end, range, start;
      start = thisYear("5/25", "16:00");
      end = thisYear("5/26", "3:00");
      range = new Twix(start, end);
      return assertEqual(2, range.countDays());
    });
    return it("works fine for all-day events", function() {
      var end, range, start;
      start = thisYear("5/25");
      end = thisYear("5/26");
      range = new Twix(start, end, true);
      return assertEqual(2, range.countDays());
    });
  });

  describe("daysIn()", function() {
    var assertSameDay;
    assertSameDay = function(first, second) {
      assertEqual(first.year(), second.year());
      assertEqual(first.month(), second.month());
      return assertEqual(first.date(), second.date());
    };
    it("provides 1 day if the range includes 1 day", function() {
      var end, iter, range, start;
      start = thisYear("5/25", "3:00");
      end = thisYear("5/25", "14:00");
      range = new Twix(start, end);
      iter = range.daysIn();
      assertSameDay(thisYear("5/25"), iter.next());
      return assertEqual(null, iter.next());
    });
    it("provides 2 days if the range crosses midnight", function() {
      var end, iter, range, start;
      start = thisYear("5/25", "16:00");
      end = thisYear("5/26", "3:00");
      range = new Twix(start, end);
      iter = range.daysIn();
      assertSameDay(thisYear("5/25"), iter.next());
      assertSameDay(thisYear("5/26"), iter.next());
      return assertEqual(null, iter.next());
    });
    return it("provides 366 days if the range is a year", function() {
      var end, iter, results, start;
      start = thisYear("5/25", "16:00");
      end = thisYear("5/25", "3:00").add('years', 1);
      iter = new Twix(start, end).daysIn();
      results = (function() {
        var _results;
        _results = [];
        while (iter.hasNext()) {
          _results.push(iter.next());
        }
        return _results;
      })();
      return assertEqual(366, results.length);
    });
  });

}).call(this);
