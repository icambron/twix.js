var moment = require('moment');
require('./dist/twix');

var ends = [{end: '2013-06-01T11:00'}, {end: '2013-06-08T11:00'}, {end: '2013-06-08', allDay: true}, {end: '2015-03-07', allDay: true}],
    locales = ['en-us', 'en-gb'];

var loc, allDay;

for (var i in ends){
  console.log("");
  for (var j in locales){
    loc = locales[j];
    allDay = ends[i].allDay || false;
    console.log(loc, allDay, '\t', moment('2013-06-01T10:00').locale(loc).twix(ends[i].end, {allDay: allDay}).format());
  }
}
