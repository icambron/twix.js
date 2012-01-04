Twix is a simple JS library for formatting date ranges. It currently depends on [moment](http://momentjs.com/)

## Installing ##

### Nodejs ###

    npm install twix

### Browser ###

```html
<script src="moment.js"></script>
<script src="twix.js"></script>
```

## Using ##

```js
var t = new Twix("5/25/1982", "5/26/1982", {allDay: true});
t.toString(); //=> 'May 25 - 26, 1982'
```

I'll add the full documentation here, in the meantime, check out the tests.

## TODO ##

 * Minified version
 * Remove moment dependency?
 * Format duration of range (e.g. "1 hour")
 * Format time until start of range (e.g. "in 1 hour")
 * Autodetect allDay
 * 24-hour time