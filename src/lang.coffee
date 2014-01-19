lang = (moment, Twix) ->
  before = moment.lang()

  Twix.registerLang "fr",
    twentyFourHour: true
    allDayMonth:
      fn: (options) -> (date) -> date.format "#{options.dayFormat} #{options.monthFormat}"
      slot: 3
    month:
      slot: 3
    date:
      slot: 2

  Twix.registerLang "fr-ca",
    twentyFourHour: true
    allDayMonth:
      fn: (options) -> (date) -> date.format "#{options.dayFormat} #{options.monthFormat}"
      slot: 3
    month:
      slot: 3
    date:
      slot: 2

  moment.lang before

if module? && module.exports?
  module.exports = lang

if typeof(define) == "function" && define.amd
  define ["moment", "twix"], (moment, Twix) -> lang(moment, Twix)

if @Twix && @moment
  lang @moment, @Twix
