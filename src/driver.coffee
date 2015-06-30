r = Npm.require('rethinkdb')
Future = Npm.require('fibers/future')

syncify = (f) ->
  (args...) ->
    fut = new Future()
    callback = Meteor.bindEnvironment (error, result) ->
      if error
        fut.throw(error)
      else
        fut.return(result)
    f.apply(this, R.append(callback, args))
    return fut.wait()

class RethinkDB
  constructor: ({host, port, db, authKey}={}) ->
    host    = host    or process.env.RETHINK_HOST or 'localhost'
    post    = post    or process.env.RETHINK_URL or '28015'
    db      = db      or 'test'
    authKey = authKey or process.env.RETHINK_AUTH_KEY or undefined

    connect = Meteor.wrapAsync(r.connect, r)
    @connection = connect({host, port, db, authKey})

  fetch: (query) ->
    @toArray(@run(query))

  run: syncify (query, callback) ->
    query.run(@connection, callback)

  next: syncify (cursor, callback) ->
    cursor.next(callback)

  toArray: syncify (cursor, callback) ->
    cursor.toArray(callback)

  each: syncify (cursor, callback) ->
    cursor.each(callback)

  tableExists: (name) ->
    tables = @run r.tableList()
    return (R.indexOf(name, tables) isnt -1)

  isEmpty: (tableQuery) ->
    return (Rethink.run(tableQuery.count()) is 0)

  hasIndex: (name, tableQuery) ->
    indexNames = Rethink.run(tableQuery.indexList())
    return (R.indexOf(name, indexNames) isnt -1)

  cursor: (query) ->
    cursor = @run(query.changes({squash:true, includeStates:true}))
    cursor.each Meteor.bindEnvironment (err, row) ->
      if err then throw new Meteor.Error(err)
      console.log(row)
    return cursor

    # cursor.close()