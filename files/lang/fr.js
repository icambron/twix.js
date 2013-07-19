(function() {
  var lang;

  lang = function(Twix) {
    return Twix.registerLang("fr", {
      twentyFourHour: true,
      allDayMonth: {
        fn: function(options) {
          return function(date) {
            return date.format("" + options.dayFormat + " " + options.monthFormat);
          };
        },
        slot: 3
      },
      month: {
        slot: 3
      },
      date: {
        slot: 2
      }
    });
  };

  if ((typeof module !== "undefined" && module !== null) && (module.exports != null)) {
    module.exports = lang;
  } else {
    lang(Twix);
  }

}).call(this);
