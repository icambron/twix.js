# Twix.js

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

## Vitals

Info          | Badges
------------- | -------------
Version       | [![Version][release-version-image]][release-url] [![NPM version][npm-version-image]][npm-url] ![Bower version][bower-version-image]
License       | [![MIT License][license-image]][license]
Popularity    | [![NPM downloads][npm-downloads-image]][npm-url]
Testing       | [![Build Status][travis-image]][travis-url] [![Code Coverage][coveralls-image]][coveralls-url]
Quality       | [![Code Climate][code-climate-img]][code-climate-url] [![Dependencies][gemnasium-image]][gemnasium-url]
Phasers       | ![Phasers to stun][phasers-image]|

## Documentation

You can find comprehensive docs here:

**[Detailed documentation](http://icambron.github.io/twix.js/docs.html)**

Breaking change in 0.7.0: Twix formatting internationalization (just French, really) is no longer supported. It doesn't seem to have had a lot of use, and it's pain to maintain. Don't worry, we still support Moment's internationalized tokens.

## Building

If you want to build and test Twix for yourself, `make` wraps everything you need:

Command          | Function
-----------------|---------
`make configure` | Install dependencies (same as `npm install`)
`make build`     | Compile JS
`make test`      | Run Mocha suite
`make lint`      | Linter
`make bench`     | Microbenchmarks

## Contributing

Patches are welcome!

 * Submit pull requests to the `develop` branch. I merge develop to master when we cut a release.
 * Don't include your changes to the generated `.js` files in the patch; they're much harder to merge. I'll generate them when I cut the release.
 * Make sure you run the linter and the tests before submitting a PR.

## Changelog

[CHANGELOG][]

## Copyright and License

Copyright 2012-2015 Isaac Cambron and contributors. Distributed under the MIT License. See [LICENSE][] for details.

[license-image]: http://img.shields.io/badge/license-MIT-blue.svg?style=flat-square
[license]: LICENSE.md

[changelog]: CHANGELOG.md

[release-url]: https://github.com/icambron/twix.js/releases/latest
[release-version-image]: https://img.shields.io/github/release/icambron/twix.js.svg?style=flat-square
[npm-url]: https://npmjs.org/package/twix
[npm-version-image]: http://img.shields.io/npm/v/twix.svg?style=flat-square
[bower-version-image]: https://img.shields.io/bower/v/twix.svg?style=flat-square

[npm-downloads-image]: http://img.shields.io/npm/dm/twix.svg?style=flat-square

[travis-url]: http://travis-ci.org/icambron/twix.js
[travis-image]: http://img.shields.io/travis/icambron/twix.js/develop.svg?style=flat-square

[coveralls-url]: https://coveralls.io/github/icambron/twix.js
[coveralls-image]: https://img.shields.io/coveralls/icambron/twix.js/develop.svg?style=flat-square

[code-climate-img]: https://img.shields.io/codeclimate/github/icambron/twix.js.svg?style=flat-square
[code-climate-url]: https://codeclimate.com/github/icambron/twix.js

[gemnasium-url]: https://gemnasium.com/icambron/twix.js
[gemnasium-image]: https://img.shields.io/gemnasium/icambron/twix.js.svg?style=flat-square

[phasers-image]: https://img.shields.io/badge/phasers-stun-yellow.svg?style=flat-square
