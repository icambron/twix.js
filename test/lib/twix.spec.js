(function() {
  var Twix, assert_equal, moment, run_batch, this_year;

  if (typeof module !== "undefined") {
    moment = require("moment");
    assert_equal = require('assert').equal;
    Twix = require("../../lib/twix");
  } else {
    moment = window.moment;
    Twix = window.Twix;
    assert_equal = function(a, b) {
      if (a !== b) throw new Error("Found " + a + ", expected " + b);
    };
  }

  run_batch = function(options, tests) {
    var t, _i, _len, _results;
    _results = [];
    for (_i = 0, _len = tests.length; _i < _len; _i++) {
      t = tests[_i];
      _results.push(it("is as expected for " + t.name, function() {
        var twix;
        twix = new Twix(t.start, t.end, options);
        return assert_equal(twix.toString(), t.result);
      }));
    }
    return _results;
  };

  this_year = function(partial, time) {
    var full_date;
    full_date = "" + partial + "/" + (moment().year());
    if (time) full_date += " " + time;
    return full_date;
  };

  describe("simple ranges", function() {
    return run_batch({}, [
      {
        name: "different year, different date",
        start: "5/25/1982 5:30 AM",
        end: "5/26/1983 3:30 PM",
        result: 'May 25, 1982, 5:30 AM - May 26, 1983, 3:30 PM'
      }, {
        name: "same year, different day",
        start: "5/25/1982 5:30 AM",
        end: "5/26/1982 3:30 PM",
        result: 'May 25, 5:30 AM - May 26, 3:30 PM, 1982'
      }, {
        name: "this year, different day",
        start: this_year("5/25", "5:30 AM"),
        end: this_year("5/26", "3:30 PM"),
        result: 'May 25, 5:30 AM - May 26, 3:30 PM'
      }, {
        name: "same day, different times",
        start: "5/25/1982 5:30 AM",
        end: "5/25/1982 3:30 PM",
        result: 'May 25, 1982, 5:30 AM - 3:30 PM'
      }, {
        name: "same day, different times, same meridian",
        start: "5/25/1982 5:30 AM",
        end: "5/25/1982 6:30 AM",
        result: 'May 25, 1982, 5:30 - 6:30 AM'
      }
    ]);
  });

  describe("rounded times", function() {
    return run_batch({}, [
      {
        name: "rounded time",
        start: "5/25/1982 5:00 AM",
        end: "5/25/1982 7:00 AM",
        result: "May 25, 1982, 5 - 7 AM"
      }, {
        name: "mixed times",
        start: "5/25/1982 5:00 AM",
        end: "5/25/1982 5:30 AM",
        result: "May 25, 1982, 5 - 5:30 AM"
      }
    ]);
  });

  describe("all day events", function() {
    return run_batch({
      allDay: true
    }, [
      {
        name: "one day",
        start: "5/25/2010",
        end: "5/25/2010",
        result: "May 25, 2010"
      }, {
        name: "same month",
        start: this_year("5/25"),
        end: this_year("5/26"),
        result: "May 25 - 26"
      }, {
        name: "different month",
        start: this_year("5/25"),
        end: this_year("6/1"),
        result: "May 25 - Jun 1"
      }, {
        name: "explicit year",
        start: "5/25/1982",
        end: "5/26/1982",
        result: "May 25 - 26, 1982"
      }, {
        name: "different year",
        start: "5/25/1982",
        end: "5/25/1983",
        result: "May 25, 1982 - May 25, 1983"
      }, {
        name: "different year, different month",
        start: "5/25/1982",
        end: "6/1/1983",
        result: "May 25, 1982 - Jun 1, 1983"
      }
    ]);
  });

}).call(this);
