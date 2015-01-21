locale = (moment, Twix) ->
  before = moment.locale()

  Twix.registerLocale "fr",
    twentyFourHour: true
    allDayMonth:
      fn: (options) -> (date) -> date.format "#{options.dayFormat} #{options.monthFormat}"
      slot: 3
    month:
      slot: 3
    date:
      slot: 2

  Twix.registerLocale "fr-ca",
    twentyFourHour: true
    allDayMonth:
      fn: (options) -> (date) -> date.format "#{options.dayFormat} #{options.monthFormat}"
      slot: 3
    month:
      slot: 3
    date:
      slot: 2

  moment.locale before

module?.exports = locale

if typeof(define) == "function" && define.amd
  define ["moment", "twix"], (moment, Twix) -> locale(moment, Twix)

if @Twix
  if @moment
    locale(@moment, @Twix)
  else if moment?
    # Also checks globals (Meteor)
    locale(moment, @Twix)
