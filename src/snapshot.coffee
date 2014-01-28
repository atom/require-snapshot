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

  # Ignore native module.
  if module.filename.substr(-5, 5) is '.node'
    return null

  id: module.id
  filename: module.filename
  paths: module.paths
  children: new Array(module.children.length)  # preallocate array for performance.

dumpModuleTree = (parent, predicate) ->
  root = serializeModule parent
  return null unless root

  for module, i in parent.children
    # Notice that we still dump the module even when the user doesn't want it,
    # because some modules used by it still need to be cached.
    serialized = dumpModuleTree module, predicate
    root.children[i] = serialized

    # Skip this module.
    continue unless serialized?

    # The 'null' content means it should not be cached.
    if predicate module.name
      serialized.content = readModuleContent module
    else
      serialized.content = null
  root

snapshot = (parent, predicate) ->
  JSON.stringify dumpModuleTree(parent, predicate)

exports.snapshot = snapshot
