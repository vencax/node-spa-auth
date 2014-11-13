var pbkdf2 = require('pbkdf2-sha256');
var jwt = require('jsonwebtoken');
var passport = require('passport');


var tokenValidInMinutes = process.env.TOKEN_VALIDITY_IN_MINS || 60;

var _embedToken = function(user) {
  var token = jwt.sign(user, process.env.SERVER_SECRET, {
    expiresInMinutes: tokenValidInMinutes
  });
  user.token = token;
};


var manips = require('./lib/manips');
exports.sequelizeManip = manips.sequelize;
exports.dummyManip = manips.dummy;


exports.init = function(app, usermanip, bodyParser) {

  app.use(passport.initialize());

  if ('FBCLIENTID' in process.env) {

    require('./lib/facebook')(app, usermanip, passport, _embedToken);

  }

  if ('TWITTERCONSUMERKEY' in process.env) {

    require('./lib/twitter')(app, usermanip, passport, _embedToken);

  }

  // var GithubStrategy = require('passport-github').Strategy;

  if ('GOOGLECLIENTID' in process.env) {

    require('./lib/google')(app, usermanip, passport, _embedToken);

  }

  require('./lib/local')(app, usermanip, passport, _embedToken, bodyParser);

};
