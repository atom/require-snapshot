snapshot = require('./snapshot').snapshot
buildCache = require('./build-cache').buildCache

exports.save = (module, filter=-> true) ->
  throw new TypeError('Bad argument') unless module?
  snapshot module, filter

exports.restore = (module, cacheContent) ->
  throw new TypeError('Bad argument') unless module? and cacheContent?
  buildCache require.cache, module, cacheContent
