lang = (moment, Twix) ->
moment.lang 'fr-ca', twix:  twix: Twix._extend {}, Twix.defaults,
  twentyFourHour: true
  allDayMonth:
    fn: (options) -> (date) -> date.format "#{options.dayFormat} #{options.monthFormat}"
    slot: 3
  month:
    slot: 3
  date:
    slot: 2

if module? && module.exports?
  module.exports = lang
else
  lang(moment, Twix)
