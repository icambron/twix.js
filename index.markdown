---
layout: default
title: Twix.js
---

<a id="home"></a>

Twix.js is a [Moment.js](http://momentjs.com) plugin for working with time ranges. Use it to manipulate, interrogate, and [intelligently format](#smarFormatting) a block of time.

##<a id="gettingStarted"></a>Getting started

###Browser

Grab [the
file](https://raw.github.com/icambron/twix.js/master/bin/twix.min.js) as
well as
[moment.js](https://raw.github.com/timrwood/moment/1.3.0/moment.min.js).
Then simply reference twix after moment:

```html
<script src="moment.min.js"></script>
<script src="twix.min.js"></script>
```

###Node.js

To install, run

```
npm install twix
```

And then in your application, just `require` moment:

```js
require('twix');
```

##<a id="creatingRanges"></a>Creating ranges

Twix mixes the `twix()` method into all moment objects. You use that to create a time range from that moment:

```js
var range = moment(startTime).twix(endTime); //=> from start time until end time
```

You can also create a range directly from the moment constructor:

```js
var range = moment.twix(startTime, endTime);
```

You can also create a range from a moment duration object. See [Creating a duration from a range](#rangeFromDuration).

###Inputs accepted

To specify the dates, you can pass in anything that can be processed by moment's one-argument constructor. This includes:

 * A JS Date object
 * A moment object
 * Anything parsable by the Date() constructor. This includes most obvious date formats.


If you want more complicated parsing, just use moment for that:

```js
var startTime = moment('2012 juillet', 'YYYY MMM', 'fr');
var endTime = moment('2012 August', 'YYYY MMM', 'en');
var range = moment.twix(startTime, endTime); //=> from July 1 to August 1
```

###All day ranges

Regular events last from a specific moment in time to another specific moment in time. All-day events, on the other hand, capture the concept of the entire day. It's an important distinction in several respects:

 * The ranges are actually different times. A regular event from 5/25 - 5/26 is from 5/25, 12:00 AM to 5/26, 12:00, where as the all day event is over both days.
 * All of Twix's functions respect the all-day semantics when comparing or
 * The time range is formatted to differently -- see [below](#formattingAllDay) for more information.

You create an all-day range by passing `true` as an extra argument to `twix()`:

```js
moment('5/25/1982').twix('5/26/1982', true);
```

##<a id="basicOperations"></a>Basic operations

###same()

Does the event begin and end on the same minute/hour/day/month/year? Any time period understood by moment will work.

```js
moment("5/25/1982 5:00").twix("5/26/1982 6:00").same("day");  //=> false
moment("5/25/1982 5:00").twix("5/25/1982 6:00").same("day");  //=> true
moment("5/25/1982 5:00").twix("5/25/1982 6:00").same("year"); //=> true
```

###isPast()

Does the range end in the past?

```js
moment("5/25/1982").twix("5/26/1982").isPast(); //=> true
```

###isFuture()

Does the range start in the future?

```js
moment("5/25/2054").twix("5/26/2054").isFuture(); //=> true
```

###isCurrent()

Does the range include the current time?

```js
moment.subtract(1, "hour").twix(moment().add(1, "hour")).isCurrent(); //=> true
```

###count()
The number of minutes/hours/days/months/years the range includes. Any time period understood by moment will work.

```js
moment("5/25/1982 5:00").twix("5/25/1982 6:00").count("days")  //=> 1
moment("5/25/1982 5:00").twix("5/26/1982 6:00").count("days")  //=> 2
```

###iterate()
Returns an iterator that will return each a moment for each time period in during the range. Any time period understood by moment will work.

```js
var iter = moment("5/25/1982 5:00").twix("5/26/1982 6:00").iterate("days");
iter.next(); //=> moment("5/25/1982")
iter.next(); //=> moment("5/26/1982")
iter.next(); //=> null
```

##<a id="multipleRanges"></a>Working with multiple ranges

###overlaps()
Does this range overlap another range?

```js
var range1 = moment("5/25/1982", "5/30/1982");
var range2 = moment("5/27/1982", "6/13/1982");

range1.overlaps(range2); //=> true
```

###engulfs()
Does this range have a start time before and an end time after another range?

```js
var range1 = moment("5/25/1982", "8/30/1982");
var range2 = moment("5/27/1982", "6/13/1982");

range1.overlaps(range2); //=> true
range2.overlaps(range1); //=> false
```

###equals()
Are these two ranges the same? Equality also requires that either both or neither ranges are all-day.

```js
var range1 = moment("5/25/1982", "8/30/1982");
var range2 = moment("5/25/1982", "8/30/1982");

range1.equals(range2); //=> true
range2.equals(range1); //=> true
```

###merge()
Produce a range that has the minimum start time and the maximum end time of the two ranges.

```js
var range1 = moment("5/25/1982", "5/30/1982");
var range2 = moment("5/27/1982", "6/13/1982");

range1.merge(range2); //=> 5/25/82 - 6/13/1982
```

##<a id="momentDurations"></a>Working with Moment durations

Moment now has [durations](http://momentjs.com/docs/#/durations/), which a block of time, but not a *specific* block of time, just a period of, say, hours or days. Twix provides some utilities for working with durations.

###<a id="rangeFromDuration"></a>Creating a range from a duration
You can create a range from a duration by anchoring it to a time:

```js
var d = moment.duration(2, "days");
var range = d.afterMoment("5/25/1982"); //=> 5/25/1982 - 5/27/1982
```

You can also make the range extend backward by the duration:

```js
var d = moment.duration(2, "days");
d.beforeMoment("5/25/1982"); //=> 5/23/1982 - 5/25/1982
```

###Creating a duration from a range
You can also create durations from ranges:

```js
var range = moment("5/25/1982").twix("5/28/1982");
range.asDuration("days"); //=> duration object with {days: 3}
```

##<a id="basicFormatting"></a>Basic formatting

While Twix's formatting options focus on [smart formatting](#smartFormatting), it also has a few other formatting methods.

###humanizeLength()
Get the length of a range in human-readable terms.

```js
var range = moment("5/25/1982 8:00").twix("5/25/1982 10:00");
range.humanizeLength(); //=> "2 hours"

range = moment("5/25/1982").twix("1/1/2013");
range.humanizeLength(); //=> 31 years
```

###simpleFormat()

Simple format produces a very simple string representation of the range. It's useful if you don't want all the cleverness of smart formatting. The signature is `simpleFormat(momentFormat, options)` and both args are optional. Here's how it works.

```js
var range = moment("5/25/1982 9:00").twix("5/25/1982 12:00");

range.simpleFormat(); //=> '1982-05-25T09:00:00-04:00 - 1982-05-25T12:00:00-04:00'
```

It can take a Moment [formatting string](http://momentjs.com/docs/#/displaying/format/) and will format both ends of the range accordingly:

range.simpleFormat("ddd, hA"); //=> 'Tue, 9AM - Tue, 12PM'
```

All-day ranges will add some extra text:

```js
var range = moment("5/25/1982").twix("5/26/1982", true);

range.simpleFormat(); //=> '1982-05-25T00:00:00-04:00 - 1982-05-26T00:00:00-04:00 (all day)'
range.simpleFormat(YYYY-MM-DD); //=> '1982-05-25 - 1982-05-26 (all day)'
```

You can control that text through the options argument, and even get rid of it altogether:

```js
range.simpleFormat(null, {allDay: "-- all day! --"}); //=> '1982-05-25T00:00:00-04:00 - 1982-05-26T00:00:00-04:00 -- all day! --'

range.simpleFormat(null, {allDay: null}); //=> '1982-05-25T00:00:00-04:00 - 1982-05-26T00:00:00-04:00'
```

It appends some extra stuff 

##<a id="smartFormatting"></a>Smart formatting

The most important feature is formatting. By default, Twix tries to make brief, readable strings.

###<a id="formatAllDay"></a>All-day ranges

All day ranges won't show times: they're just assumed to take up the full day local time.

```js
moment("1/25/2012").twix("1/25/2012", true).format();   //=> Jan 25
moment("1/25/1982").twix("1/25/1982", true).format();   //=> Jan 25, 1982
moment("1/25/2012").twix("1/26/2012", true).format();   //=> Jan 25 - 26
moment("1/25/1982").twix("2/25/1982", true).format();   //=> Jan 25 - Feb 25, 1982
moment("1/25/1982").twix(new Date(), true).format();    //=> Jan 25, 1982 - Jan 9, 2012
```

Notice the various the different kinds of groupings and abbreviations:

 * If the entire range occurs within the current year, Twix doesn't show the year.
 * Twix only shows the year and month once if they're consistent across the range.
 * If it's all the same day, Twix doesn't show a range at all.

###Events with hours and minutes

Unless the allDay parameter is set to true, the time is considered relevant:

```js
moment("1/25/1982 9:30 AM").twix("1/25/1982 1:30 PM").format();  //=> Jan 25, 1982, 9:30 AM - 1:30 PM
moment("1/25/1982 9:30 AM").twix(new Date()).format();           //=> Jan 25, 1982, 9:30 AM - Jan 9, 2012, 3:05 AM
moment("1/25/1982").twix("1/27/1982").format();                  //=> Jan 25, 12 AM - Jan 27, 12 AM, 1982
```

### Brevity and its discontents

Twix chops off the `:00` on whole hours and, where possible, only display AM/PM once. This can be turned off:

```js
var twix = moment("5/25/2012 9:00").twix("5/25/2012 10:00");

twix.format();                                                    //=> May 25, 9 - 10 AM
twix.format({implicitMinutes: false, groupMeridiems: false});     //=> May 25, 9:00 AM - 10:00 AM
```

There's an `implicitYear` option, which you can use to always show the year, even when it's this year:

```js
var twix = moment().twix(moment().add('days', 1));
twix.format({implicitYear: false}); //=> Mar 28, 1:13 AM - Mar 29, 1:13 AM, 2013
```

### 24-hour time

Right, not everyone is American:

```js
moment("5/25/2012 16:00").twix("5/25/2012 17:00").format({twentyFourHour: true});  //=> May 25, 16:00 - 17:00
```

Notice there's no hour abbreviation.

### Changing the format

I've made the format hackable, allowing you to specify the Moment formatting parameters externally -- these are what Twix uses to format the bits and pieces of text it glues together. You can use that to adjust how, say, months are displayed:

```js
moment("1/25/2012 8:00").twix("1/25/2012 17:00").format({
  monthFormat: "MMMM",
  dayFormat: "Do"
});                                                         //=> January 25th, 8 AM - 5 PM
```

See all the `*Format` options below. You should look at [Moment's format documentation](http://momentjs.com/docs/#/displaying/format/) for more info. YMMV -- because of the string munging, not everything will act quite like you expect.

### Odds and ends

You can get rid of the space before the meridiem:

```js
moment("5/25/2012 8:00").twix("5/25/2012 17:00").format({spaceBeforeMeridiem: false})  //=> May 25, 8AM - 5PM
```

If you're showing the date somewhere else, it's sometimes useful to only show the times:

```js
moment("5/25/2012 8:00").twix("5/25/2012 17:00").format({showDate: false})            //=> 8 AM - 5 PM
```

This doesn't affect ranges that span multiple days; they still show the dates.

If you combine an all-day event with `showDate:false`, you get this:

```js
moment("1/25/2012").twix("1/25/2012", true).format({showDate: false})                //=> All day
```

That text is customizable through the `allDay` option.

### All the options

Here are all the options and their defaults

```js
{
  groupMeridiems: true,
  spaceBeforeMeridiem: true,
  showDate: true,
  showDayOfWeek: false,
  twentyFourHour: false,
  implicitMinutes: true,
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
