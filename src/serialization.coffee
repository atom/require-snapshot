bson = require 'bson'

{BSON, Long, ObjectID, Binary, Code, DBRef, Symbol, Double, Timestamp, MaxKey, MinKey} = bson.pure()
compiler = new BSON([Long, ObjectID, Binary, Code, DBRef, Symbol, Double, Timestamp, MaxKey, MinKey])

exports.serialize = (obj) ->
  compiler.serialize obj, false, true, false

exports.deserialize = (data) ->
  compiler.deserialize data
