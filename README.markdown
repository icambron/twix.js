#Twix [![Build Status](https://secure.travis-ci.org/icambron/twix.js.png?branch=develop)](http://travis-ci.org/icambron/twix.js)#

Twix is a simple but opinionated JS library for working with date ranges, and includes a customizable smart formatter. It's written in CoffeeScript and it depends on [Moment.js](http://momentjs.com/).

It allows you to do, among other things, this:

```js
var t = moment("1/25/1982 9:30 AM").twix("1/25/1982 1:30 PM");

t.format();  //=> Jan 25, 1982, 9:30 AM - 1:30 PM

t.isSame("day"); //=> true
t.humanizeDuration(); //=> "4 hours"
t.count("days"); //=> 1
```

And much more.

##[Documentation](http://icambron.github.io/twix.js/)

##Building##

If you want to build Twix for yourself, you'll need to install CoffeeScript. Then clone the repo out and run this:

    make configure build

Configure just installs the NPMs and brings in Moment as a submodule, so you only have to do that part once.

Note that the source is `src/twix.coffee`; the output is `bin/twix.js`. You can run the tests via

    make test

You can also run the tests in-browser by building and then loading `test/test.html`.

##Contributing##

Patches are welcome!

 * Submit pull requests to the `develop` branch. I merge develop to master when we cut a release.
 * Don't include your changes to the generated `.js` files in the patch; they're much harder to merge. I'll generate them when I cut the release.

Contributors to the project as of 0.4.0:
     145	Isaac Cambron           78.4%
      16	Tanguy Krotoff          8.6%
       8	Léo S                  4.3%
       5	Edmund von der Burg     2.7%
       3	Nathan White            1.6%
       3	Pikachu                 1.6%
       2	Suzanne Hamilton        1.1%
       1	andresmoschini          0.5%
       1	Thomas Durin            0.5%
       1	Andrew Wirick           0.5%

##Changelog##

 * **0.4.0**  Simplified internationalization support (**possibly breaking change for those few people using French support**), added more complex iteration durations. Reverted build complexity.

 * **0.3.0**: AMD support, basic internationalization support, bug fix for `countInner` and `iterateInner`. Component and bower support. New build system and code organization.

 * **0.2.2**: Added `isValid` and `intersection`, fixed `overlaps` for adjacent times, renamed `merge` to `union`, added deprecation warnings.

 * **0.2.1**: Added `countInner`, `contains`, `iterateInner`, and `length`

 * **0.2.0**: Deprecated `sameDay`, `sameYear`, `countDays`, `daysIn`, `past`, and `duration`. Added `isSame`, `humanizeLength`, `asDuration`, `isPast`, `isFuture`, `isCurrent`. Added duration methods. Emphasized moment() monkey patch methods over Twix() constructor. Some bug fixes.

 * Older versions - wasn't tracking.

##License (MIT)##

Copyright (c) 2012 Isaac Cambron

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
