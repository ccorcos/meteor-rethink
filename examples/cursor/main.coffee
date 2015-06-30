if Meteor.isServer
  @Rethink = new RethinkDB()

  unless Rethink.tableExists('numbers')
    console.log "Creating 'numbers' table..."
    Rethink.run(r.tableCreate('numbers'))
    console.log "...done"

  if Rethink.isEmpty(r.table('numbers'))
    console.log "Seeding numbers..."
    newDoc = (n) -> {value: n}
    data = [0...10].map(newDoc)
    Rethink.run(r.table('numbers').insert(data))
    console.log "...done"

  unless Rethink.hasIndex('value', r.table('numbers'))
    Rethink.run(r.table('numbers').indexCreate('value'))

  inc = ->
    numbers = Rethink.fetch(r.table('numbers'))
    number = Random.choice(numbers)
    Rethink.run(r.table('numbers').get(number.id).update({value:number.value+1}))

  @fetchNumbers = ->
    Rethink.fetch(r.table('numbers').orderBy('value'))

  @cursorNumbers = ->
    # Rethink.cursor(r.table('numbers'))
    Rethink.cursor(r.table('numbers').orderBy({index: r.desc('value')}))

  intervalId = null
  @startInterval = ->
    intervalId = Meteor.setInterval(inc, 1000)
  
  @stopInterval = ->
    Meteor.clearInterval(intervalId)

