var LocalStrategy = require('passport-local').Strategy;


module.exports = function(app, usermanip, passport, getToken) {

  var _verifyUser = function(username, password, done) {
    usermanip.find(username, function(err, user) {
      if (err) {
        return done(err);
      }
      if (!user) {
        return done(null, false, { message: 'Incorrect username.' });
      }
      if (!usermanip.validPassword(user, password)) {
        return done(null, false, { message: 'Incorrect password.' });
      }
      return done(null, user);
    });
  };

  passport.use(new LocalStrategy(_verifyUser));

  app.post('/login',
    passport.authenticate('local', {session: false, failWithError: true}),
    function(req, res) {
      res.send({user: req.user, token: getToken(req.user)});
    });

  // ---------------------------------------------------------------------------

  app.post('/check', function(req, res) {
    usermanip.find(req.body.email, function(err, user) {
      if(user) {
        return res.send([0]);
      } else {
        return res.send([]);
      }
    });
  });

};
