moduleCompilation = require './module-compilation'
serialization = require './serialization'
fs = require 'fs'

readModuleContent = (module) ->
  content = fs.readFileSync module.filename
  header = new Buffer('(function (exports, require, module, __filename, __dirname) {')
  footer = new Buffer('\n});')
  Buffer.concat [header, content, footer]

serializeModule = (module) ->
  # Prevent duplicate cache.
  if module.serialized
    return null
  else
    module.serialized = true

  id: module.id
  filename: module.filename
  paths: module.paths
  children: []

dumpModuleTree = (parent, predicate) ->
  # The user wants to skip this tree.
  return null unless predicate parent.filename

  root = serializeModule parent
  return null unless root?

  for module in parent.children
    serialized = dumpModuleTree module, predicate

    # Skip this module.
    continue unless serialized?

    # Only cache content of .js file.
    if moduleCompilation.getExtension(module) is '.js'
      serialized.content = readModuleContent module

    root.children.push serialized
  root

snapshot = (parent, predicate) ->
  serialization.serialize dumpModuleTree(parent, predicate)

exports.snapshot = snapshot
