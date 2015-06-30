# Meteor RethinkDB

This package allows you to use the RethinkDB in your Meteor project.

## Installation and Setup

You will have to install RethinkDB on your machine. If you're on a Mac using Homebrew:

    brew install rethinkdb

Then add this package to your Meteor project:

    meteor add ccorcos:rethink

You can get up and running quickly by starting Rethink, and then starting Meteor:

    rethinkdb start
    meteor

### CLI

I'm working on a command-line tool for this package. 
Hopefully at some point, Meteor will allow some hooks into the build system.
The main benefit of this tool is that it creates a Rethink database in `.meteor/local/rethinkdb/`
so that you can separate your projects nicely. First, download the script and make it
executable.

    curl -O https://raw.githubusercontent.com/ccorcos/meteor-rethink/master/rdb
    chmod +x rdb

Make sure this script is somewhere on your path. Then from inside your Meteor project, 
you can start Rethink and it will create a database for this project if it doesn't already exist.

    rdb start

Finally, when you use `meteor reset`, it will also clear the Rethink database because `meteor reset` clears the project's `.meteor/local/` directory. 

## API

On the server, start the database connection:

    Rethink = new RethinkDB()

This defaults to running on `http://localhost:28015/`. 
If you want to connect to a Rethink instance running elsewhere, 
you can pass an object specifying the `host`, `port`, `db`, and `authKey`.

You can also set environments variable for `RETHINK_HOST`, `RETHINK_URL`, and `RETHINK_AUTH_KEY`.

Rethink is built upon chaining queries. To wrap these queries into fibers, we provide `Rethink.run`. `Rethink.toArray` will turn a cursor into an array.

    cursor = Rethink.run(r.table('authors').orderBy({index: r.desc('posts')}).limit(1))
    results = Rethink.toArray(cursor)

You can accomplish both of these by using `Rethink.fetch`.

# To Do

Changefeeds have a couple issues. 

1) They don't consistently provide the initial documents.
2) They don't support ordered queries