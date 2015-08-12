# Twix

[![NPM version][npm-version-image]][npm-url] [![NPM downloads][npm-downloads-image]][npm-url] [![MIT License][license-image]][license] [![Build Status][travis-image]][travis-url] [![Code Coverage][coveralls-image]][coveralls-url] ![Phasers to stun][phasers-image]


Twix is a simple but opinionated JS library for working with date ranges, and includes a customizable smart formatter. It's written in CoffeeScript and it depends on [Moment.js](http://momentjs.com/).

It allows you to do, among other things, this:

```js
var t = moment("1982-01-25T09:30").twix("1982-01-25T13:30");

t.format();  //=> Jan 25, 1982, 9:30 AM - 1:30 PM

t.isSame("day"); //=> true
t.humanizeLength(); //=> "4 hours"
t.count("days"); //=> 1
```

And much more.

## [Documentation](http://icambron.github.io/twix.js/docs.html)

**Attention Moment 2.10.x users**: You need to upgrade to the latest Twix! You also should make sure not to be on Moment 2.10.0 (i.e. upgrade to the latest point release) because it has some compatibility issues with Twix.

**Breaking change in 0.7.0**: Twix formatting internationalization (just French, really) is no longer supported. It doesn't seem to have had a lot of use, and it's pain to maintain. Don't worry, we still support Moment's internationalized tokens.

## Building

If you want to build Twix for yourself, clone the repo and run this:

    make configure build

Configure just installs the NPMs (including CoffeeScript) and brings in Moment as a submodule, so you only have to do that part once.

Note that the source is `src/twix.coffee`; the output is `dist/twix.js`. You can run the tests via

    make test

You can also run the tests in-browser by building and then loading `test/test.html`.

## Contributing

Patches are welcome!

 * Submit pull requests to the `develop` branch. I merge develop to master when we cut a release.
 * Don't include your changes to the generated `.js` files in the patch; they're much harder to merge. I'll generate them when I cut the release.

## Changelog

 * **0.7.0**: Fixed bug in `xor()` and `difference()`. Fixed compatibility with other plugins. Removed custom locale support. Deprecated `twentyFourHour`. Moved `bin` to `dist`.

 * **0.6.5**: Fix for `contains()` on all-day ranges

 * **0.6.4**: Use peerDependency for Moment

 * **0.6.3**: Moment 2.10 compatibility

 * **0.6.2**: Fix `iterate` for months

 * **0.6.1**: Meteor support

 * **0.6.0**: Moment deprecations, s/lang/locale, xor, intersection, split, difference, immutability

 * **0.5.1**: Make Twix compatible with Moment 2.8.1

 * **0.5.0**: Fix intersection/overlap behavior (#36), expand signature, and deal with Moment deprecations.

 * **0.4.0**: Simplified internationalization support (**possibly breaking change for those few people using French support**), added more complex iteration durations. Reverted build complexity.

 * **0.3.0**: AMD support, basic internationalization support, bug fix for `countInner` and `iterateInner`. Component and bower support. New build system and code organization.

 * **0.2.2**: Added `isValid` and `intersection`, fixed `overlaps` for adjacent times, renamed `merge` to `union`, added deprecation warnings.

 * **0.2.1**: Added `countInner`, `contains`, `iterateInner`, and `length`

 * **0.2.0**: Deprecated `sameDay`, `sameYear`, `countDays`, `daysIn`, `past`, and `duration`. Added `isSame`, `humanizeLength`, `asDuration`, `isPast`, `isFuture`, `isCurrent`. Added duration methods. Emphasized moment() monkey patch methods over Twix() constructor. Some bug fixes.

 * Older versions - wasn't tracking.

## Copyright

Copyright 2012-2015 Isaac Cambron and contributors. Distributed under the MIT License. See [LICENSE][] for details.

[license-image]: http://img.shields.io/badge/license-MIT-blue.svg?style=flat-square
[license]: LICENSE.md

[npm-url]: https://npmjs.org/package/twix
[npm-version-image]: http://img.shields.io/npm/v/twix.svg?style=flat-square
[npm-downloads-image]: http://img.shields.io/npm/dm/twix.svg?style=flat-square

[travis-url]: http://travis-ci.org/icambron/twix.js
[travis-image]: http://img.shields.io/travis/icambron/twix.js/develop.svg?style=flat-square

[coveralls-url]: https://coveralls.io/github/icambron/twix.js
[coveralls-image]: https://img.shields.io/coveralls/icambron/twix.js/develop.svg?style=flat-square

[phasers-image]: https://img.shields.io/badge/phasers-stun-yellow.svg?style=flat-square
