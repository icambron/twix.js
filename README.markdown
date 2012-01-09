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

### Different kinds of ranges ###


### Formatting options ###


## TODO ##

 * Minified version
 * Remove moment dependency?
 * Format duration of range (e.g. "1 hour")
 * Format time until start of range (e.g. "in 1 hour")
 * Autodetect allDay
 * 24-hour time