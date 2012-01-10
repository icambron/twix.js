Twix is a simple but opinionated JS library for formatting date ranges. It currently depends on [Moment.js](http://momentjs.com/).

## Installing ##

### Nodejs ###

    npm install twix

### Browser ###

```html
<script src="moment.js"></script>
<script src="twix.js"></script>
```

## Using ##

You can create a Twix object with:

```js
new Twix(startTime, endTime);
```

or

```js
new Twix(startTime, endTime, true); //all-day range
```

The dates can be parsable strings, JS Date objects, or Moments.

## Formatting ##

### All-day ranges ###

All day ranges won't show times: they're just assumed to take up the full day local time.

```js
new Twix("1/25/2012", "1/25/2012", true).format();   //=> Jan 25
new Twix("1/25/1982", "1/25/1982", true).format();   //=> Jan 25, 1982
new Twix("1/25/2012", "1/26/2012", true).format();   //=> Jan 25 - 26
new Twix("1/25/1982", "2/25/1982", true).format();   //=> Jan 25 - Feb 25, 1982
new Twix("1/25/1982", new Date(), true).format();   //=> Jan 25, 1982 - Jan 9, 2012
```

Notice the various the different kinds of groupings and abbreviations:
 * If the entire range occurs within the current year, Twix doesn't show the year.
 * Twix only shows the year and month once if they're consistent across the range.
 * If it's all the same day, Twix doesn't show a range at all.

### Events with hours and minutes ###

Unless the allDay parameter is set to true, the time is considered relevant:

```js
new Twix("1/25/1982 9:30 AM", "1/25/1982 1:30 PM").format();  //=> Jan 25, 1982, 9:30 AM - 1:30 PM
new Twix("1/25/1982 9:30 AM", new Date()).format();           //=> Jan 25, 1982, 9:30 AM - Jan 9, 2012, 3:05 AM
new Twix("1/25/1982", "1/27/1982").format();                  //=> Jan 25, 12 AM - Jan 27, 12 AM, 1982
```

### Brevity and its discontents ###

Twix chops off the `:00` on whole hours and, where possible, only display AM/PM once. This can be turned off:

```js
var twix = new Twix("5/25/2012 9:00", "5/25/2012 10:00");

twix.format();                                                    //=> May 25, 9 - 10 AM
twix.format({implicitMinutes: false, groupMeridiems: false});     //=> May 25, 9:00 AM - 10:00 AM
```

### 24-hour time ###

Right, not everyone is American:

```js
new Twix("5/25/2012 16:00", "5/25/2012 17:00").format({twentyFourHour: true});  //=> May 25, 16:00 - 17:00
```

Notice there's no hour abberviation.

### Changing the format ###

I've made the format hackable, allowing you to specify the Moment formatting parameters externally -- these are what Twix uses to format the bits and pieces of text it glues together. You can use that to adjust how, say, months are displayed:

```js
new Twix("1/25/2012 8:00", "1/25/2012 17:00").format({
  monthFormat: "MMMM",
  dayFormat: "Do"
});                                                         //=> January 25th, 8 AM - 5 PM
```

See all the `*Format` options below. You should look at [Moment's format documentation](http://momentjs.com/docs/#/display/format) for more info. YMMV -- because of the string munging, not everything will act quite like you expect.

### Odds and ends ###

You can get rid of the space before the meridiem:

```js
new Twix("5/25/2012 8:00", "5/25/2012 17:00").format({spaceBeforeMeridiem: false})  //=> May 25, 8AM - 5PM
```

If you're showing the date somewhere else, it's sometimes useful to only show the times:

```js
new Twix("5/25/2012 8:00", "5/25/2012 17:00").format({showDate: false})            //=> 8 AM - 5 PM
```

This doesn't affect ranges that span multiple days; they still show the dates.

If you combine an all-day event with `showDate:false`, you get this:

```js
new Twix("1/25/2012", "1/25/2012", true).format({showDate: false})                //=> All day
```

That text is customizable through the `allDay` option.

### All the options ###

Here are all the options and their defaults

```js
{
  groupMeridiems: true,
  spaceBeforeMeridiem: true,
  showDate: true,
  twentyFourHour: false,
  implicitMinutes: true,
  yearFormat: "YYYY",
  monthFormat: "MMM",
  dayFormat: "D",
  meridiemFormat: "A",
  hourFormat: "h",
  minuteFormat: "mm",
  allDay: "All day"
}
```

## Other utilities ##

```js
new Twix("1/25/2012", "1/25/2012", true).sameYear()        //=> true
new Twix("1/25/2012 9:00", "1/25/2012 4:43 PM").sameDay()  //=> true
```

## TODO ##

 * Minified version
 * Remove moment dependency?
 * Format duration of range (e.g. "1 hour")
 * Format time until start of range (e.g. "in 1 hour")

## License (MIT)##

Copyright (c) 2012 Isaac Cambron

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.