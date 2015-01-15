Package.describe({
	name: "icambron:twix",
	summary: "Twix.js (official): a Moment.js plugin for working with time ranges.",
  version: "0.6.0",
});

// Makes Twix available both on the server and on the client
var where = ["client", "server"];

Package.onUse(function(api) {

	api.use("momentjs:moment", where);
	api.imply("momentjs:moment", where);

	api.add_files([
    "bin/twix.js",
	  "bin/locale.js"
	], where);
});
