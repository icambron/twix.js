Twix.js is a [Moment.js](http://momentjs.com) plugin for working with time ranges. Use it to manipulate, interrogate, and [intelligently format](#smart-formatting) a block of time. You can find the source on [Github](http://github.com/icambron/twix.js) and the docs here.

##Getting started

###Browser

Grab [the file](https://raw.github.com/icambron/twix.js/master/dist/twix.min.js) as well as [moment.js](https://raw.githubusercontent.com/moment/moment/master/min/moment.min.js). Then simply reference twix after Moment:

```html
<script src="moment.min.js"></script>
<script src="twix.min.js"></script>
```

###Browser with RequireJS

Twix supports AMD, so you can load it as a RequireJS module. Natrually, it depends on Moment:

```js
define(["moment", "twix"], function(moment){
 //you don't usually need a reference to twix itself
});
```

###Node.js

To install, run

```
npm install twix
```

And then in your application, just `require` Moment and Twix.

```js
var moment = require('moment');
require('twix');
```

##Creating ranges

Twix mixes the `twix()` method into all Moment objects. You use that to create a time range from that Moment:

```js
var range = moment(startTime).twix(endTime); //=> from start time until end time
```

You can also create a range "statically":

```js
var range = moment.twix(startTime, endTime);
```

You can also create a range from a Moment duration object. See [Creating a range from a duration](#working-with-moment-durations).

###Inputs accepted

TLDR, do one of these:

```js
someMoment.twix(otherMoment);
someMoment.twix('2012-05-25');
someMoment.twix({year: 2012, month: 5, day: 25});
someMoment.twix("05/25/1982", "MM/DD/YYYY", {parseStrict: true});
```

More comprehensively, this is the signature:

```js
moment.twix(anyMomentArg, [parseFormatString,] optionsObject);
```

That allows you to pass:

 * A JS Date object: `someMoment.twix(new Date(...))`
 * A Moment object: `someMoment.twix(otherMoment)`
 * Any other single-argument you can construct a Moment with, like an [array](http://momentjs.com/docs/#/parsing/array/), a [POJSO](http://momentjs.com/docs/#/parsing/object/), or an [ISO-compliant string](http://momentjs.com/docs/#/parsing/string/).
 * A parsable string and a parse format: `someMoment.twix('2012 August', 'YYYY MMM')`. The format is [specified by Moment](http://momentjs.com/docs/#/parsing/string-format/). You can also use Moment's strict parsing by specifying the `parseStrict` option, like `someMoment.twix('2012 August', 'YYYY MMM', {parseStrict: true})`.

If you want more complicated parsing, just use Moment for that:

```js
var startTime = moment('2012 juillet', 'YYYY MMM', 'fr');
var endTime = moment('2012 August', 'YYYY MMM', 'en');
var range = startTime.twix(endTime); //=> from July 1 to August 1
```

###Using all-day ranges

Regular ranges last from a specific millisecond another specific millisecond. All-day ranges, on the other hand, capture the concept of the entire day. It's an important distinction in several respects:

 * The ranges are actually different times. A regular range from 5/25 - 5/26 is from 5/25, 12:00 AM to 5/26, 12:00, where as the all day range is over both days.
 * All of Twix's functions respect all-day semantics.
 * The time range is formatted differently -- see [below](#formatting-all-day) for more information.

You create an all-day range by specifying the `allDay` option:

```js
moment('1982-05-25').twix('1982-05-26', {allDay: true});
```

You can also pass a boolean instead of the option hash, and Twix will use it as the all-day option:

```js
moment('1982-05-25').twix('1982-05-26', true);
```

##Basic operations

###isValid

Returns false if the range's start time is after the end time, and true
otherwise.

```js
moment().twix(moment()).isValid();                    //=> true
moment().twix(moment().add(1, "day")).isValid();      //=> true
moment().twix(moment().subtract(1, "day")).isValid(); //=> false
```

###isSame

Does the range begin and end on the same minute/hour/day/month/year? Any time period understood by Moment will work.

```js
moment("1982-05-25T05:00").twix("1982-05-26T06:00").isSame("day");  //=> false
moment("1982-05-25T05:00").twix("1982-05-25T06:00").isSame("day");  //=> true
moment("1982-05-25T05:00").twix("1982-05-25T06:00").isSame("year"); //=> true
```

###isPast

Does the range end in the past?

```js
moment("1982-05-25").twix("1982-05-26").isPast(); //=> true
```

###isFuture

Does the range start in the future?

```js
moment("2054-05-25").twix("2054-05-26").isFuture(); //=> true
```

###isCurrent

Does the range include the current time?

```js
moment.subtract(1, "hour").twix(moment().add(1, "hour")).isCurrent(); //=> true
```

###contains

Determine whether a range contains a time. You can pass in a Moment object, a JS date, or a string parsable by the Date constructor. The range is considered inclusive of its endpoints.

```js
moment("1982-05-25").twix("1982-05-28").contains("1982-05-26"); //=> true
```

###length
Calculate the length of the range in terms of minutes/hours/days/months/etc. Any time period understood by Moment will work.

```js
moment("1982-05-25T5:30").twix("1982-05-25T6:30").length("hours")  //=> 1
moment("1982-05-25T5:00").twix("1982-05-30T6:00").length("days")   //=> 6
```

See also [asDuration()](#reating-a-duration-from-a-range).

###count
The number of minutes/hours/days/months/years the range includes, even in part. Any time period understood by Moment will work.

```js
moment("1982-05-25T5:00").twix("1982-05-25T6:00").count("days")  //=> 1
moment("1982-05-25T5:00").twix("1982-05-26T6:00").count("days")  //=> 2
```

Note that this is counting sections of the calendar, not periods of time. So it asks "what dates are included by this range?" as opposed to "how many 24-hour periods are contained in this range?" For the latter, see [length()](#length).

###countInner
<a id="counter-inner-int"></a>
The number of minutes/hours/days/months/years that are completely contained, such that both the beginning and end of the period fall inside the range. Any time period understood by Moment will work.

```js
moment("1982-05-25T5:00").twix("1982-05-25T6:00").countInner("days")  //=> 0
moment("1982-05-24T5:00").twix("1982-05-26T6:00").countInner("days")  //=> 1
```

See also [count()](#count) and [length()](#length).

###iterate
<a id="iterate-int"></a>
Returns an iterator that will return each a Moment for each time period included in the range. Any time period understood by Moment will work.

```js
var iter = moment("1982-05-25T5:00").twix("1982-05-26T6:00").iterate("days");
iter.hasNext(); //=> true
iter.next(); //=> moment("1982-05-25")
iter.next(); //=> moment("1982-05-26")
iter.hasNext(); //=> false
iter.next(); //=> null
```

You can also iterate with more complicated periods like "2 hours" or "4 days".

```js
var iter = moment("16", "hh").twix(endTime).iterate(2, 'hours');
iter.next().format('LT'); //=> '4:00 PM'
iter.next().format('LT'); //=> '6:00 PM'
```

It also works with arbitrary durations objects:

```js
var duration = moment.duration({hours: 2, minutes: 30, seconds: 20});
var iter = moment("16", "hh").twix(endTime).iterate(duration);
iter.next().format('LT'); //=> '4:00 PM'
iter.next().format('LT'); //=> '6:30 PM'
iter.next().format('LT'); //=> '9:00 PM'
```

###iterateInner
Like [iterate()](#iterate), but only for days completely contained in the range.

```js
var iter = moment("1982-05-24T5:00").twix("1982-05-27T6:00").iterateInner("days");
iter.hasNext(); //=> true
iter.next(); //=> moment("1982-05-25")
iter.next(); //=> moment("1982-05-26")
iter.hasNext(); //=> false
iter.next(); //=> null
```

`iterateInner` takes all the same duration arguments as `iterate`.

###start

Returns the start of the range as a Moment instance. Mutating the returned value does not affect the range. This accessor is often useful when using Twix functions that create ranges, such as `split()` and `intersection()`.


```js
moment("1982-05-24T05:00").twix(someTime).start(); //=> moment("1982-05-25T05:00")
```

###end

Returns the end of the range as a Moment instance. Mutating the returned value does not affect the range. This accessor is often useful when using Twix functions that create ranges, such as `split()` and `intersection()`.


```js
 moment(someTime).twix("1982-05-27T06:00").end(); //=> moment("1982-05-27T06:00")
```

##Multiple ranges

###overlaps
Does this range overlap another range?

```js
var range1 = moment("1982-05-25").twix("1982-05-30");
var range2 = moment("1982-05-27").twix("1982-06-13");

range1.overlaps(range2); //=> true
```

###engulfs
Does this range have a start time before and an end time after another range?

```js
var range1 = moment("1982-05-25").twix("1982-08-30");
var range2 = moment("1982-05-27").twix("1982-06-13");

range1.engulfs(range2); //=> true
range2.engulfs(range1); //=> false
```

###equals
Are these two ranges the same? Equality also requires that either both or neither ranges are all-day.

```js
var range1 = moment("1982-05-25").twix("1982-08-30");
var range2 = moment("1982-05-25").twix("1982-08-30");

range1.equals(range2); //=> true
range2.equals(range1); //=> true
```

###union
Produce a range that has the minimum start time and the maximum end time of the two ranges.

```js
var range1 = moment("1982-05-25").twix("1982-05-30");
var range2 = moment("1982-05-27").twix("1982-06-13");

range1.union(range2); //=> 5/25/82 - 6/13/1982
```

###intersection
Produce a range that has the maximum start time and the minimum end time of the two ranges.

```js
var range1 = moment("1982-05-25").twix("1982-05-30");
var range2 = moment("1982-05-27").twix("1982-06-13");

range1.intersection(range2); //=> 5/27/82 - 5/30/1982
```

###xor
Returns an array of ranges that are in one range or the other, but not both.

```js
var range1 = moment("1982-05-24").twix("1982-05-28", true);
var range2 = moment("1982-05-22").twix("1982-05-26", true);
var xorred = range1.xor(range2);

xorred[0].format() //=> 'May 22 - 23, 1982'
xorred[1].format() //=> 'May 27 - 28, 1982'
```

The array returned may contain 0, 1, or 2 ranges.

###difference
Returns an array of ranges that are in this range but not the target range.

```js
var range1 = moment("1982-05-23").twix("1982-05-28", true);
var range2 = moment("1982-05-25").twix("1982-05-26", true);
var diff = range1.difference(range2);

diff[0].format(); //=> 'May 23 - 24, 1982'
diff[1].format(); //=> 'May 27 - 28, 1982'
```

The array returned may contain 0, 1, or 2 ranges.

###split
Splits a range into multiple ranges. Can take either a duration, the arguments for creating a duration, or any number of times.

```js
var range = moment("1982-05-25T05:01").twix("1982-05-25T07:30");

var splits = range.split(1, "hour");
splits[0].format({hideDate: true}); //=> '5:01 - 6:01 AM'
splits[1].format({hideDate: true}); //=> '6:01 - 7:01 AM'
splits[2].format({hideDate: true}); //=> '7:01 - 7:30 AM'

//other signatures
range.split(moment.duration({"h": 1})).length; //=> 3
range.split(moment("1982-05-25T06:00")).length; //=> 2
range.split(moment("1982-05-25T06:00"), moment("1982-05-25T07:00")).length; //=> 3
```

##Moment durations

Moment now has [durations](http://momentjs.com/docs/#/durations/), which represent a block of time, but not a *specific* block of time, just a period of, say, hours or days. Twix provides some utilities for working with durations.

###Creating a range from a duration
You can create a range from a duration by anchoring it to a time:

```js
var d = moment.duration(2, "days");
var range = d.afterMoment("1982-05-25"); //=> 5/25/1982 - 5/27/1982
```

You can also make the range extend backward by the duration:

```js
var d = moment.duration(2, "days");
d.beforeMoment("1982-05-25"); //=> 5/23/1982 - 5/25/1982
```

###Creating a duration from a range
You can also create durations from ranges:

```js
var range = moment("1982-05-25").twix("1982-05-28");
range.asDuration("days"); //=> duration object with {days: 3}
```

See also [length()](#length).

##Basic formatting

While Twix's formatting options focus on [smart formatting](#smart-formatting), it also has a few other formatting methods.

###humanizeLength
Get the length of a range in human-readable terms.

```js
var range = moment("1982-05-25T8:00").twix("1982-05-25T10:00");
range.humanizeLength(); //=> "2 hours"

range = moment("1982-05-25").twix("2013-01-01");
range.humanizeLength(); //=> 31 years
```

###simpleFormat

Simple format produces a very simple string representation of the range. It's useful if you don't want all the cleverness of smart formatting. The signature is `simpleFormat(momentFormat, options)` and both args are optional. Here's how it works.

```js
var range = moment("1982-05-25T9:00").twix("1982-05-25T12:00");

range.simpleFormat(); //=> '1982-05-25T09:00:00-04:00 - 1982-05-25T12:00:00-04:00'
```

But you probably want to pass a Moment [formatting string](http://momentjs.com/docs/#/displaying/format/). It will format both ends of the range accordingly:

```js
range.simpleFormat("ddd, hA"); //=> 'Tue, 9AM - Tue, 12PM'
```

All-day ranges will add some extra text:

```js
var range = moment("1982-05-25").twix("1982-05-26", {allDay: true});

range.simpleFormat(); //=> '1982-05-25T00:00:00-04:00 - 1982-05-26T00:00:00-04:00 (all day)'
range.simpleFormat(YYYY-MM-DD); //=> '1982-05-25 - 1982-05-26 (all day)'
```

You can control that text through the options argument, and even get rid of it altogether:

```js
range.simpleFormat(null, {allDay: "-- all day! --"}); //=> '1982-05-25T00:00:00-04:00 - 1982-05-26T00:00:00-04:00 -- all day! --'

range.simpleFormat(null, {allDay: null}); //=> '1982-05-25T00:00:00-04:00 - 1982-05-26T00:00:00-04:00'
```

You can also control the spacing and divider. You can set it on individual calls or globally:

```js
range.simpleFormat("HH:mm", {template: function(left, right){return left + " | " + right;}}); //=> '16:21 | 17:21'
```

Or you can set it globally:

```js
moment.twixClass.formatTemplate = function(left, right){return left + " | " + right;};
range.simpleFormat("HH:mm"); //=> '16:29 | 17:29'
```

##Smart formatting

The most important feature is formatting. By default, Twix tries to make brief, readable strings.

###The basics

Twix's `format` method returns a string showing the range. Called with no arguments it uses the default options for how to do that. The most important part of that is that it elides as much redundant information as it can. For example, if the range begins and ends today, it doesn't specify today's date twice. This makes for short, natural-looking time ranges.

```js
moment("1982-01-25T09:00").twix("1982-01-25T11:00").format();  //=> 'Jan 25, 1982, 9 - 11 AM'
moment("1982-01-25T9:00").twix("1982-01-26T13:00").format(); //=> 'Jan 25, 9 AM - Jan 26, 1 PM, 1982'
```

###Formatting all-day ranges

<a id="format-all-day-int"></a>

All day ranges won't show times: they're just assumed to take up the full day local time.

```js
moment("2012-01-25").twix("2012-01-25", {allDay: true}).format();   //=> Jan 25
moment("1982-01-25").twix("1982-01-25", {allDay: true}).format();   //=> Jan 25, 1982
moment("2012-01-25").twix("2012-01-26", {allDay: true}).format();   //=> Jan 25 - 26
moment("1982-01-25").twix("1982-02-25", {allDay: true}).format();   //=> Jan 25 - Feb 25, 1982
moment("1982-01-25").twix(new Date(), {allDay: true}).format();    //=> Jan 25, 1982 - Jan 9, 2012
```

Notice the various the different kinds of groupings and abbreviations:

 * If the entire range occurs within the current year, Twix doesn't show the year.
 * Twix only shows the year and month once if they're consistent across the range.
 * If it's all the same day, Twix doesn't show a range at all.

###Ranges with hours and minutes

Unless the allDay parameter is set to true, the time is considered relevant:

```js
moment("1982-01-25T9:30").twix("1/25/1982 1:30 PM").format();  //=> Jan 25, 1982, 9:30 AM - 1:30 PM
moment("1982-01-25T9:30").twix(new Date()).format();           //=> Jan 25, 1982, 9:30 AM - Jan 9, 2012, 3:05 AM
moment("1982-01-25").twix("1982-01-27").format();              //=> Jan 25, 12 AM - Jan 27, 12 AM, 1982
```

### Brevity and its discontents

Twix chops off the `:00` on whole hours and, where possible, only display AM/PM once. This can be turned off:

```js
var twix = moment("2012-05-25T9:00").twix("2012-05-25T10:00");

twix.format();                                                    //=> May 25, 9 - 10 AM
twix.format({implicitMinutes: false, groupMeridiems: false});     //=> May 25, 9:00 AM - 10:00 AM
```

There's an `implicitYear` option, which you can use to always show the year, even when it's this year:

```js
var twix = moment().twix(moment().add('days', 1));
twix.format({implicitYear: false}); //=> Mar 28, 1:13 AM - Mar 29, 1:13 AM, 2013
```

Finally, `implicitDate` is just like `implicitYear` but for hiding the date if it's today. But it defaults to `false`.

### 24-hour time

Right, not everyone is American. If you use a Moment locale for the range's start, like "en-gb", Twix will automatically use its hour format setting.

Otherwise, simply override the `hourFormat` option.

```js
moment("2012-05-25T16:00").twix("2012-05-25T17:00").format({hourFormat: "H"});
//=> May 25, 16:00 - 17:00
```

This uses Moment's formatting tokens ("H" = 1- or 2-digit 24-hour time, "HH" = always 2-digit, whereas "h" and "hh" are the American versions). Notice there minutes are there in 24-hour time even if they're zero.

The old `twentyFourHour: true` setting is no longer supported.

### Changing the format

I've made the format hackable, allowing you to specify the Moment formatting parameters externally -- these are what Twix uses to format the bits and pieces of text it glues together. You can use that to adjust how, say, months are displayed:

```js
moment("2012-01-25T8:00").twix("2012-01-25T17:00").format({
  monthFormat: "MMMM",
  dayFormat: "Do"
});                                                   //=> January 25th, 8 AM - 5 PM
```

See all the `*Format` options below. You should look at [Moment's format documentation](http://momentjs.com/docs/#/displaying/format/) for more info. YMMV -- because of the string munging, not everything will act quite like you expect.

### Hiding things

You can get rid of the space before the meridiem:

```js
moment("2012-05-25T8:00").twix("2012-05-25T17:00").format({spaceBeforeMeridiem: false});
//=> May 25, 8AM - 5PM
```

If you're showing the date somewhere else, it's sometimes useful to only show the times:

```js
moment("2012-05-25T8:00").twix("2012-05-25T17:00").format({hideDate: true}); //=> 8 AM - 5 PM
```

If you combine an all-day range with `hideDate: true`, you get this:

```js
moment("2012-01-25").twix("2012-01-25", {allDay: true}).format({hideDate: true}); //=> All day
```

That text is customizable through the `allDay` option.

If you would like to hide the times you can use `hideTime: true`:

```js
moment("2012-05-25T8:00").twix("2012-05-27T17:00").format({hideTime: true}); //=> May 25 - May 27, 2012
```

If you would like to hide the year, specify `hideYear: true`:

```js
moment("2012-05-25").twix("2012-05-27").format({hideYear: true}); //=> May 25 - May 27
```

### All the options

Here are all the options and their defaults

```js
{
  groupMeridiems: true,
  spaceBeforeMeridiem: true,
  showDayOfWeek: false,
  hideTime: false,
  hideDate: false,
  hideYear: false,
  implicitMinutes: true,
  implicitDate: false,
  implicitYear: true,
  yearFormat: "YYYY",
  monthFormat: "MMM",
  weekdayFormat: "ddd",
  dayFormat: "D",
  meridiemFormat: "A",
  hourFormat: "h",
  minuteFormat: "mm",
  allDay: "all day",
  explicitAllDay: false,
  lastNightEndsAt: 0
}
```

##Source code

Twix is open source (MIT License) and hosted on Github [here](http://github.com/icambron/twix.js). Instructions for building/contributing are there.
