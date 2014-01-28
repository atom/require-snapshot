fs = require 'fs'
path = require 'path'
vm = require 'vm'
Module = require 'module'

compileModule = (module, content) ->
  require = (path) ->
    Module._load path, module
  require.resolve = (request) ->
    Module._resolveFilename request, module
  require.main = process.mainModule
  require.extensions = Module._extensions
  require.cache = Module._cache

  exports = module.exports
  filename = module.filename
  dirname = path.dirname filename

  compiled = vm.runInThisContext content, {filename}
  compiled.apply exports, [exports, require, module, filename, dirname]

buildCacheFromLeaf = (cache, parent, leaf) ->
  # User didn't want to cache this.
  return null unless leaf?.content?
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
  compileModule module, leaf.content
  console.log 'Adding', module

  # Add parent's children array (it's not used by node actually).
  parent.children.push module
  # Add to cache.
  cache[leaf.filename] = module

  buildCacheFromLeaves cache, module, leaf.children

buildCacheFromLeaves = (cache, parent, leaves) ->
  buildCacheFromLeaf cache, parent, module for module in leaves

buildCacheFromTree = (cache, root, tree) ->
  if tree.id isnt '.' or root.filename isnt tree.filename
    console.error "Cache file is for #{tree.filename}"
    return

  buildCacheFromLeaves cache, root, tree.children

buildCache = (cache, root, str) ->
  buildCacheFromTree cache, root, JSON.parse(str)

exports.buildCache = buildCache