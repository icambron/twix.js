#Twix [![Build Status](https://secure.travis-ci.org/icambron/twix.js.png?branch=master)](http://travis-ci.org/icambron/twix.js)#

Twix is a simple but opinionated JS library for working with date ranges, and includes a customizable smart formatter. It's written in CoffeeScript and it depends on [Moment.js](http://momentjs.com/).

It allows you to do, among other things, this:

```js
var t = new Twix("1/25/1982 9:30 AM", "1/25/1982 1:30 PM");

t.format();  //=> Jan 25, 1982, 9:30 AM - 1:30 PM

t.sameDay(); //=> true
t.duration(); //=> "4 hours"
t.countDays(); //=> 1
```

And much more.

##Documentation##

Docs are [here](https://github.com/icambron/twix.js/wiki/Documentation).

## Installing ##

### Nodejs ###

    npm install twix

### Browser ###

Grab [the file](https://raw.github.com/icambron/twix.js/master/bin/twix.min.js) as well as [moment.js](https://raw.github.com/timrwood/moment/1.3.0/moment.min.js). Then:

```html
<script src="moment.min.js"></script>
<script src="twix.min.js"></script>
```

##Building##

If you want to build Twix for yourself, clone the repo out and run this:

    make configure build

Configure just installs the NPMs and brings in Moment as a submodule, so you only have to do that part once. 

Note that the source is `src/twix.coffee`; the output is `bin/twix.js`. You can run the tests via

    make test
    
You can also run the tests in-browser by building and then loading `test/test.html`.

## Future plans ##

For the broad aims of Twix 2.0, see the [future plans](https://github.com/icambron/twix.js/wiki/Future-plans) page.

## License (MIT)##

Copyright (c) 2012 Isaac Cambron

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
