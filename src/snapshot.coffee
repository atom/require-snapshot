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

dumpModuleTree = (parent) ->
  root = serializeModule parent
  return null unless root?

  for module in parent.children
    serialized = dumpModuleTree module

    # Skip this module.
    continue unless serialized?

    # Only cache content of .js file.
    if module.filename.substr(-3, 3) is '.js'
      serialized.content = readModuleContent module

    root.children.push serialized
  root

snapshot = (parent) ->
  serialization.serialize dumpModuleTree(parent)

exports.snapshot = snapshot
