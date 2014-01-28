fs = require 'fs'

readModuleContent = (module) ->
  content = fs.readFileSync module.filename
  "(function (exports, require, module, __filename, __dirname) { #{content}\n});"

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
  root = serializeModule parent
  return null unless root?

  for module in parent.children
    # Notice that we still dump the module even when the user doesn't want it,
    # because some modules used by it still need to be cached.
    serialized = dumpModuleTree module, predicate

    # Skip this module.
    continue unless serialized?

    # The user doesn't want it.
    continue unless predicate module.filename

    # Only cache content of .js file.
    if module.filename.substr(-3, 3) is '.js'
      serialized.content = readModuleContent module

    root.children.push serialized
  root

snapshot = (parent, predicate) ->
  JSON.stringify dumpModuleTree(parent, predicate)

exports.snapshot = snapshot
