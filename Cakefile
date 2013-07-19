fs = require "fs"
coffee = require "coffee-script"
Uglify = require "uglify-js"
Mocha = require "mocha"

task "build", ->
  invoke "ensure-directories"
  invoke "build-twix"
  invoke "build-langs"
  invoke "build-tests"
  invoke "minify"

task "clean", -> eachFile "files", fs.unlinkSync

task "test", ->
  invoke "build"
  invoke "test-node"

task "ensure-directories", ->
  for dir in ["files", "files/lang", "test/files"]
    fs.mkdirSync dir unless fs.existsSync(dir)

task "build-twix", -> compileFile "src/twix.coffee", "files/twix.js"

task "build-langs", ->
  allContent = ""
  for file in fs.readdirSync "src/lang"
    content = fs.readFileSync "src/lang/#{file}", "utf8"
    allContent += "\n" + content

    output = compile wrapLang content
    fs.writeFileSync "files/lang/#{file.split(".")[0]}.js", output

  output = compile wrapLang allContent
  fs.writeFileSync "files/lang/lang.js", output

task "build-tests", -> compileFile "test/twix.spec.coffee", "test/files/twix.spec.js"

task "minify", ->
  eachFile "files", (path, file) ->
    return if path.indexOf(".min.js") > -1

    output = Uglify.minify(path).code
    outputPath = path.replace ".js", ".min.js"
    fs.writeFileSync outputPath, output

task "test-node", ->
  mocha = new Mocha reporter: "spec"
  mocha.addFile "test/files/twix.spec.js"
  mocha.run (failures) -> process.exit failures

compile = (code) ->
  try
    coffee.compile code
  catch e
    throw e.toString()

compileFile = (src, dest) ->
  content = fs.readFileSync src, "utf8"
  output = compile content
  fs.writeFileSync dest, output

wrapLang = (content) ->
  begin = "lang = (moment, Twix) ->\n"
  end = """

    if module? && module.exports?
      module.exports =  lang
    else
      lang moment, Twix
  """

  endented = ("\t#{line}" for line in content.toString().split("\n")).join("\n")

  begin + endented + end

eachFile = (dir, callback) ->
  for file in fs.readdirSync dir
    path = dir + "/" + file
    if fs.statSync(path).isFile()
      callback path
    else
      eachFile path, callback
