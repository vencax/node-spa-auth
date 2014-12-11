var pbkdf2 = require('pbkdf2-sha256');
var jwt = require('jsonwebtoken');
var passport = require('passport');


var tokenValidInMinutes = process.env.TOKEN_VALIDITY_IN_MINS || 60;
var userInfoValidity


var _getToken = function(user) {
  return jwt.sign(JSON.parse(JSON.stringify(user)), process.env.SERVER_SECRET, {
    expiresInMinutes: tokenValidInMinutes
  });
};

var _pingFrontend = function(req, res) {
  var token = jwt.sign(req.user, process.env.SERVER_SECRET, {
    expiresInMinutes: process.env.EMAIL_VALIDATION_TOKEN_DURATION || 24 * 60
  });
  res.cookie('sptoken', token, {
    maxAge: 60 * 60 * 1000, httpOnly: true,
    secure: (process.env.NODE_ENV === 'development') ? false : true
  });

  // function _clientHost() {
  //   return req.headers.referer.match(/https?:\/\/[^\/]{2,256}/)[0];
  // }
  res.redirect((process.env.CLIENTAPPURL || '') + '/_socialcallback');
};

exports.manips = require('./lib/manips');


exports.init = function(app, usermanip, bodyParser, sendMail) {

  app.use(passport.initialize());

  app.use(bodyParser.json());
  require('./lib/local')(app, usermanip, passport, _getToken);
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
          res.send({user: decoded, token: _getToken(decoded)});
        }
      });
    });
  }

  app.use(function(err, req, res, next) {
    if(err.name && err.name === 'AuthenticationError') {
      return res.status(400).send('CREDENTIALS_NOT_VALID');
    }
    next(err);
  });

};
