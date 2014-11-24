var pbkdf2 = require('pbkdf2-sha256');
var jwt = require('jsonwebtoken');
var passport = require('passport');


var tokenValidInMinutes = process.env.TOKEN_VALIDITY_IN_MINS || 60;

var _embedToken = function(user) {
  var token = jwt.sign(user, process.env.SERVER_SECRET, {
    expiresInMinutes: tokenValidInMinutes
  });
  user.dataValues.token = token;
};

var _pingFrontend = function(req, res) {
  var token = jwt.sign(req.user, process.env.SERVER_SECRET, {
    expiresInMinutes: process.env.EMAIL_VALIDATION_TOKEN_DURATION || 24 * 60
  });
  res.cookie('sptoken', token, {
    maxAge: 10 * 1000, httpOnly: true,
    secure: process.env.SECURED_PING_COOKIE || true
  });
  res.redirect('/_socialcallback');
};

var manips = require('./lib/manips');
exports.sequelizeManip = manips.sequelize;
exports.dummyManip = manips.dummy;


exports.init = function(app, usermanip, bodyParser, sendMail) {

  app.use(passport.initialize());

  require('./lib/local')(app, usermanip, passport, _embedToken, bodyParser);
  require('./lib/registration')(app, usermanip, sendMail);

  var _initUserInfoRoute = false;

  if ('FBCLIENTID' in process.env) {
    require('./lib/facebook')(app, usermanip, passport, _pingFrontend);
    _initUserInfoRoute = true;
  }

  if ('TWITTERCONSUMERKEY' in process.env) {
    require('./lib/twitter')(app, usermanip, passport, _pingFrontend);
    _initUserInfoRoute = true;
  }

  // var GithubStrategy = require('passport-github').Strategy;

  if ('GOOGLECLIENTID' in process.env) {
    require('./lib/google')(app, usermanip, passport, _pingFrontend);
    _initUserInfoRoute = true;
  }

  if(_initUserInfoRoute) {
    var cookieParser = require('cookie-parser');
    app.use(cookieParser());

    app.get('/userinfo', function(req, res) {
      var token = req.cookies.sptoken;
      jwt.verify(token, process.env.SERVER_SECRET, function(err, decoded) {
        if (err) {
          res.status(404).send('TOKEN_NOT_VALID');
        } else {
          _embedToken(decoded);
          res.send(decoded);
        }
      });
    });
  }

};
