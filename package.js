Package.describe({
  name: 'ccorcos:rethink',
  summary: 'RethinkDB API for Meteor',
  version: '0.0.1',
  git: 'https://github.com/ccorcos/meteor-rethink'
});

Npm.depends({
  rethinkdb: '2.0.2'
})

Package.onUse(function(api) {
  api.versionsFrom('1.0');
  api.use([
    'coffeescript',
    'ramda:ramda@0.13.0'
  ], 'server');
  api.addFiles('src/driver.coffee', 'server');
  api.export('r');
  api.export('RethinkDB')
});
