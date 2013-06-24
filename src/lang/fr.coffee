moment.lang('fr', twix: $.extend(true, {}, Twix.defaults, 
  twentyFourHour: true
  allDayMonth:
    fn: (options) -> (date) -> date.format "#{options.dayFormat} #{options.monthFormat}"
    slot: 3
  month:
    slot: 3
  date:
    slot: 2
))