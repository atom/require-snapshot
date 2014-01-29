moduleCompilation = require './module-compilation'
serialization = require './serialization'

buildCacheFromLeaf = (cache, parent, leaf) ->
  # Do not override existing cache.
  return cache[leaf.filename] if cache[leaf.filename]

  module =
    id: leaf.id
    parent: parent
    exports: {}
    filename: leaf.filename
    loaded: true
    children: []
    paths: leaf.paths

  console.log 'Adding module', module.filename
  buildCacheFromLeaves cache, module, leaf.children

  # Compile after all the children have been compiled, otherwise the cache would
  # not be hit.
  console.log 'Compiling module', module.filename
  moduleCompilation.compileModule module, leaf.content

  # Add parent's children array (it's not used by node actually).
  parent.children.push module
  # Add to cache.
  cache[leaf.filename] = module

buildCacheFromLeaves = (cache, parent, leaves) ->
  buildCacheFromLeaf cache, parent, module for module in leaves

buildCacheFromTree = (cache, root, tree) ->
  if root.filename isnt tree.filename
    console.error "Cache file is for #{tree.filename}"
    return

  buildCacheFromLeaves cache, root, tree.children

buildCache = (cache, root, str) ->
  buildCacheFromTree cache, root, serialization.deserialize(str)

exports.buildCache = buildCache
