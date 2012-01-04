(function() {
  var Twix, moment;

  if (typeof module !== "undefined") {
    moment = require('moment');
  } else {
    moment = window.moment;
  }

  if (typeof moment === "undefined") throw "Can't find moment";

  Twix = (function() {

    function Twix(start, end, options) {
      this.start = moment(start);
      this.end = moment(end);
      this.options = options || {};
    }

    Twix.prototype.toString = function() {
      var common_bucket, end_bucket, fold, format, formatters, global_first, process, start_bucket, together, _i, _len,
        _this = this;
      formatters = [
        {
          name: "year",
          fn: function(date) {
            return date.format("YYYY");
          },
          pre: ", ",
          slot: 2,
          skip: this.start.year() === moment().year() && this.start.year() === this.end.year()
        }, {
          name: "month",
          fn: function(date) {
            return date.format("MMM");
          },
          slot: 0,
          skip: !this.options.allDay,
          pre: " "
        }, {
          name: "date",
          fn: function(date) {
            return date.format("D");
          },
          slot: 1,
          skip: !this.options.allDay,
          pre: " "
        }, {
          name: "month and date",
          fn: function(date) {
            return date.format("MMM D");
          },
          slot: 0,
          skip: this.options.allDay,
          pre: " "
        }, {
          name: "meridian",
          fn: function(t) {
            return t.format("A");
          },
          slot: 4,
          skip: this.options.twentyFour || this.options.allDay,
          pre: " "
        }, {
          name: "time",
          fn: function(date) {
            if (date.minutes() === 0) {
              return date.format("h");
            } else {
              return date.format("h:mm");
            }
          },
          skip: this.options.allDay,
          pre: ", ",
          slot: 3
        }
      ];
      start_bucket = [];
      end_bucket = [];
      common_bucket = [];
      together = true;
      process = function(format) {
        var end_str, start_group, start_str;
        start_str = format.fn(_this.start);
        end_str = format.fn(_this.end);
        start_group = {
          format: format,
          value: function() {
            return start_str;
          }
        };
        if (end_str === start_str && together) {
          return common_bucket.push(start_group);
        } else {
          if (together) {
            together = false;
            common_bucket.push({
              format: {
                slot: format.slot,
                pre: ""
              },
              value: function() {
                return "" + (fold(start_bucket)) + " -" + (fold(end_bucket, true));
              }
            });
          }
          start_bucket.push(start_group);
          return end_bucket.push({
            format: format,
            value: function() {
              return end_str;
            }
          });
        }
      };
      for (_i = 0, _len = formatters.length; _i < _len; _i++) {
        format = formatters[_i];
        if (format.skip !== true) process(format);
      }
      global_first = true;
      fold = function(array, skip_pre) {
        var local_first, section, str, _j, _len2, _ref;
        local_first = true;
        str = "";
        _ref = array.sort(function(a, b) {
          return a.format.slot - b.format.slot;
        });
        for (_j = 0, _len2 = _ref.length; _j < _len2; _j++) {
          section = _ref[_j];
          if (!global_first) {
            if (local_first && skip_pre) {
              str += " ";
            } else {
              str += section.format.pre;
            }
          }
          str += section.value();
          global_first = false;
          local_first = false;
        }
        return str;
      };
      return fold(common_bucket);
    };

    return Twix;

  })();

  if (typeof module !== "undefined") {
    module.exports = Twix;
  } else {
    window.Twix = Twix;
  }

}).call(this);
