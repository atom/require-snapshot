path = require 'path'
vm = require 'vm'
Module = require 'module'

getExtension = (module) ->
  extension = path.extname(module.filename) ? '.js'
  extension = '.js' unless Module._extensions[extension]?
  extension

compileJSModule = (module, content) ->
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

compileOtherModule = (module) ->
  module.require = (path) -> Module._load path, module
  module._compile = Module::_compile.bind module

  Module._extensions[getExtension(module)](module, module.filename)

compileModule = (module, content) ->
  if content?
    compileJSModule module, content
  else
    compileOtherModule module

exports.getExtension = getExtension
exports.compileModule = compileModule
