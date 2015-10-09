#!/usr/bin/env node

require('coffee-script/register');
var path = require('path');
var pkg = require(path.join(__dirname, 'package.json'));
var program = require('commander');

var cmdValue, dataValue;

program
  .version(pkg.version)
  .arguments('<cmd> [data]')
  .action(function (cmd, data) {
     cmdValue = cmd;
     dataValue = data;
  })
  .option('-u, --user <username>', 'user that has to be processed')
  .parse(process.argv);

program.parse(process.argv);

var Sequelize = require('sequelize');
var sequelize = new Sequelize(process.env.DATABASE_URL);
require('./models')(sequelize, Sequelize);
var manip = require('./lib/manips').sequelize(sequelize);
var Mngmt = require('./lib/management')(manip);

function onError(err) {
  console.error(err);
  process.exit(1);
}

switch (cmdValue) {

  case 'create':
    try {
      user = JSON.parse(dataValue);
    } catch(err) {
      onError('user attributes in JSON missing or corrupt')
    }
    Mngmt.create(user, function(err, user) {
      if(err) { return onError(err); }
      console.log("user created");
    });
    break;

  case 'update':
      try {
        data = JSON.parse(dataValue);
        var uname = data.uname;
        var change = data.change;
        Mngmt.update(uname, change, function(err, user) {
          if(user === null) {
            onError("user " + uname + " not found");
          }
          if(err) { return onError(err); }
          console.log(uname + " updated");
        });
      } catch(err) {
        onError('user attributes in JSON missing or corrupt')
      }
      break;

  case undefined:
    onError("no command given!")
    break;

  default:
    onError('unknown command given!');
}
