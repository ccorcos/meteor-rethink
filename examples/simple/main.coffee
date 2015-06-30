# RethinkDB example following the 10-minute guide
# http://www.rethinkdb.com/docs/guide/javascript/

if Meteor.isServer
  @Rethink = new RethinkDB()

  unless Rethink.tableExists('authors')
    console.log "Creating 'authors' table..."
    Rethink.run(r.tableCreate('authors'))
    console.log "...done"

  if Rethink.isEmpty(r.table('authors'))
    console.log "Seeding authors..."
    data = [
      { 
        name: "William Adama", 
        tv_show: "Battlestar Galactica",
        posts: [
          {title: "Decommissioning speech", content: "The Cylon War is long over..."},
          {title: "We are at war", content: "Moments ago, this ship received word..."},
          {title: "The new Earth", content: "The discoveries of the past few days..."}
        ]
      },
      { 
        name: "Laura Roslin", 
        tv_show: "Battlestar Galactica",
        posts: [
          {title: "The oath of office", content: "I, Laura Roslin, ..."},
          {title: "They look like us", content: "The Cylons have the ability..."}
        ]
      },
      { 
        name: "Jean-Luc Picard", 
        tv_show: "Star Trek TNG",
        posts: [
          {title: "Civil rights", content: "There are some words I've known since..."}
        ]
      }
    ]
    Rethink.run(r.table('authors').insert(data))
    console.log "...done"

  unless Rethink.hasIndex('posts', r.table('authors'))
    Rethink.run(r.table('authors').indexCreate('posts', r.row('posts').count()))


Meteor.methods
  mostActiveAuthor: ->
    if Meteor.isServer
      result = Rethink.fetch(r.table('authors').orderBy({index: r.desc('posts')}).limit(1))
      return result[0]

if Meteor.isClient
  Session.setDefault('author', {})

  Template.main.onRendered ->
    Meteor.call 'mostActiveAuthor', (err, author) ->
      Session.set('author', author)

  Template.main.helpers
    author: () -> Session.get('author')
