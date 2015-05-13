Package.describe({
  name: "momentjs:twix",
  summary: "Twix.js (official) by Isaac Cambron: a Moment.js plugin for working with date ranges.",
  version: "0.6.4",
  git: "https://github.com/icambron/twix.js.git",
  documentation: "README.markdown",
});

// Makes Twix available both on the server and on the client
var where = ["client", "server"];

Package.onUse(function(api) {

  // Please see latest available version for momentjs:moment on
  // https://atmospherejs.com/momentjs/moment
  api.use("momentjs:moment@2.9.0", where);
  api.imply("momentjs:moment@2.9.0", where);

  api.add_files([
    "bin/twix.js",
    "bin/locale.js"
  ], where);
});
