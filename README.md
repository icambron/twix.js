# Twix.js

[![MIT License][license-image]][license] [![Build Status][travis-image]][travis-url] [![Version][release-version-image]][release-url] [![NPM version][npm-version-image]][npm-url]

Twix is a comprehensive JS library for working with date ranges, and includes a customizable smart formatter. It's written in CoffeeScript and it depends on [Moment.js](http://momentjs.com/).

Some examples:

```js
var t = moment("1982-01-25T09:30").twix("1982-01-25T13:30");

t.format();  //=> Jan 25, 1982, 9:30 AM - 1:30 PM

t.isSame("day"); //=> true
t.humanizeLength(); //=> "4 hours"
t.count("days"); //=> 1
t.intersection(otherRange); //=> another range
```

See the [documentation][documentation-url] for more.

## Documentation

You can find comprehensive docs here:

**[Detailed documentation][documentation-url]**

**Breaking change in 1.0.0**: Removed the deprecated `showYear` and `showDate` smart formatter options. Use `hideYear`, `hideDate`, `implicitYear`, and `implicitDate` instead.

## Building

If you want to build and test Twix for yourself, `make` wraps everything you need:

Command                | Function
-----------------------|---------
`make configure`       | Install dependencies (same as `npm install`)
`make` or `make build` | Compile `src/*.coffee` to `dist/*.js`
`make test`            | Run Mocha suite
`make lint`            | Linter
`make bench`           | Microbenchmarks

## Contributing

Patches are welcome!

 * Don't include your changes to the generated `.js` files in the patch; they're much harder to merge. I'll generate them when I cut the release.
 * Make sure you run the linter and the tests before submitting a PR. Use `make lint` and `make test`.
 * If you make a change that will need documentation, make the appropriate update to [docs](docs/docs.md). It will get published to the website on the next release.

## Changelog

[CHANGELOG][]

## Copyright and License

Copyright 2012-2015 Isaac Cambron and contributors. Distributed under the MIT License. See [LICENSE][] for details.

![Phasers to stun][phasers-image]

[documentation-url]: https://isaaccambron.com/twix.js/docs.html

[license-image]: http://img.shields.io/badge/license-MIT-blue.svg?style=flat-square
[license]: LICENSE.md

[changelog]: CHANGELOG.md

[release-url]: https://github.com/icambron/twix.js/releases/latest
[release-version-image]: https://img.shields.io/github/release/icambron/twix.js.svg?style=flat-square
[npm-url]: https://npmjs.org/package/twix
[npm-version-image]: http://img.shields.io/npm/v/twix.svg?style=flat-square
[bower-version-image]: https://img.shields.io/bower/v/twix.svg?style=flat-square

[travis-url]: http://travis-ci.org/icambron/twix.js
[travis-image]: http://img.shields.io/travis/icambron/twix.js/master.svg?style=flat-square

[coveralls-url]: https://coveralls.io/github/icambron/twix.js
[coveralls-image]: https://img.shields.io/coveralls/icambron/twix.js/master.svg?style=flat-square

[gemnasium-url]: https://gemnasium.com/icambron/twix.js
[gemnasium-image]: https://img.shields.io/gemnasium/icambron/twix.js.svg?style=flat-square

[phasers-image]: https://img.shields.io/badge/phasers-stun-brightgreen.svg?style=flat-square
